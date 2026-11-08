import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ScientificArticle {
  final String title, authors, journal, date, link, doi, abstractText, source;
  ScientificArticle({required this.title, required this.authors, required this.journal,
    required this.date, required this.link, required this.doi, required this.abstractText,required this.source});
  factory ScientificArticle.fromEuropePmc(Map<String,dynamic> j) {
    final doi=j['doi']?.toString()??'';
    final id=j['id']?.toString()??'';
    final src=j['source']?.toString()??'MED';
    final url=doi.isNotEmpty ? 'https://doi.org/$doi'
      : 'https://europepmc.org/article/${Uri.encodeComponent(src)}/${Uri.encodeComponent(id)}';
    final journalMap=j['journalInfo'] is Map ? (j['journalInfo'] as Map)['journal'] : null;
    final journal=journalMap is Map ? (journalMap['title']?.toString()??'') : '';
    return ScientificArticle(
      title:j['title']?.toString()??'Sin título', authors:j['authorString']?.toString()??'Autor no disponible',
      journal:journal, date:j['firstPublicationDate']?.toString()??j['firstIndexDate']?.toString()??'',
      link:url, doi:doi, abstractText:(j['abstractText']?.toString()??'').replaceAll(RegExp(r'<[^>]*>'),' '),source:src);
  }
}

class ScientificSearchResult {
  final List<ScientificArticle> articles;
  final int total;
  final String finalQuery;
  ScientificSearchResult(this.articles,this.total,this.finalQuery);
}

class ScientificService {
  static const api='https://www.ebi.ac.uk/europepmc/webservices/rest/search';
  static Future<ScientificSearchResult> search({required Subject subject, Topic? topic,
    required String keywords, required String language, DateTime? from,DateTime? to}) async {
    // Europe PMC indexes many biomedical sources, not every journal worldwide.
    final raw=keywords.trim().isNotEmpty ? keywords.trim() : topic?.title ?? '';
    final clean=raw.replaceAll(RegExp(r'[<>\[\]{}]'),' ').trim();
    final base=clean.isEmpty ? subject.scientificQuery : clean;
    final fragments=['($base)'];
    // Cuando el usuario escribe un término, el área médica elegida es un filtro real.
    if(clean.isNotEmpty && subject.scientificQuery.trim().isNotEmpty) {
      fragments.add('(${subject.scientificQuery})');
    }
    if (clean.isEmpty && topic==null && subject.scientificQuery.trim().isEmpty) {
      throw StateError('Escribe un término de búsqueda.');
    }
    if (language!='Todos') fragments.add('LANG:${language.toLowerCase()}');
    if(from!=null||to!=null){
      String date(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      fragments.add('FIRST_PDATE:[${from==null?'*':date(from)} TO ${to==null?'*':date(to)}]');
    }
    final query=fragments.join(' AND ');
    final uri=Uri.parse(api).replace(queryParameters:{'query':query,'format':'json','resultType':'core','pageSize':'25','sort':'FIRST_PDATE_D desc'});
    final response=await http.get(uri,headers:{'Accept':'application/json'}).timeout(const Duration(seconds:25));
    if(response.statusCode!=200) throw StateError('Europe PMC respondió con código ${response.statusCode}.');
    final data=jsonDecode(utf8.decode(response.bodyBytes)) as Map<String,dynamic>;
    final entries=((data['resultList'] as Map?)?['result'] as List?)??[];
    return ScientificSearchResult(entries.map((e)=>ScientificArticle.fromEuropePmc(Map<String,dynamic>.from(e))).toList(),
      (data['hitCount'] as num?)?.toInt()??entries.length,query);
  }
}
