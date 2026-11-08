import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_elite/models.dart';
import 'package:med_elite/services/internal_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Catálogo definitivo: 44 asignaturas, 1337 temas y anatomía roja', () async {
    final subjects = (jsonDecode(await rootBundle.loadString('assets/data/subjects.json')) as List)
      .map((e) => Subject.fromJson(Map<String,dynamic>.from(e))).toList();
    final topics = (jsonDecode(await rootBundle.loadString('assets/data/topics.json')) as List)
      .map((e) => Topic.fromJson(Map<String,dynamic>.from(e))).toList();
    expect(subjects.length,44);
    expect(topics.length,1337);
    expect(subjects.first.color.toUpperCase(),'#FF3300');
    expect(topics.first.rotation,0);
  });
  test('Shock aparece en múltiples materias en títulos reales del temario', () async {
    final subjects = (jsonDecode(await rootBundle.loadString('assets/data/subjects.json')) as List)
      .map((e) => Subject.fromJson(Map<String,dynamic>.from(e))).toList();
    final topics = (jsonDecode(await rootBundle.loadString('assets/data/topics.json')) as List)
      .map((e) => Topic.fromJson(Map<String,dynamic>.from(e))).toList();
    final hits=InternalSearchService.search(subjects:subjects,topics:topics,
      resources:[],query:'SHOCK');
    expect(hits.map((h)=>h.topic.id),containsAll([466,794,989]));
  });
  test('Busca títulos y subtítulos de capítulos, nunca el cuerpo ni las notas', () {
    final s=Subject.fromJson({'id':18,'year':4,'start':711,'end':725,'name':'Cardiología',
      'shortName':'Cardiología','color':'#CC0000','scientificQuery':'cardiology'});
    final t=Topic.fromJson({'id':711,'subjectId':18,'title':'CARDIOLOGÍA GENERAL','rotation':null});
    final r=StudyResource(id:'test',subjectId:18,topicId:711,title:'Manual de prueba',
      subtitle:'Clínica cardiovascular',headings:['Shock cardiogénico','Infarto agudo de miocardio'],
      category:'Libros oficiales y bibliografía',kind:'drive',url:'https://example.org',access:'free',
      source:'Prueba',note:'Este cuerpo contiene la palabra hipotermia.');
    final hits=InternalSearchService.search(subjects:[s],topics:[t],resources:[r],query:'shock');
    expect(hits.length,1);
    expect(hits.first.field,'Capítulo / subtítulo del libro');
    final noHits=InternalSearchService.search(subjects:[s],topics:[t],resources:[r],query:'hipotermia');
    expect(noHits,isEmpty);
  });
  test('La normalización omite tildes', () {
    expect(InternalSearchService.matches('ÓRGANOS DE LA RESPIRACIÓN','organos respiracion'),isTrue);
  });
}
