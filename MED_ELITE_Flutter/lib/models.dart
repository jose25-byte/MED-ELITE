import 'package:flutter/material.dart';

Color hexColor(String value) => Color(int.parse(value.replaceFirst('#', '0xFF')));

class Subject {
  final int id, year, start, end;
  final String name, shortName, color, scientificQuery;
  Subject.fromJson(Map<String, dynamic> j)
      : id = j['id'], year = j['year'], start = j['start'], end = j['end'],
        name = j['name'], shortName = j['shortName'],
        color = j['color'], scientificQuery = j['scientificQuery'];
  Color get accent => hexColor(color);
  int get count => end - start + 1;
}

class Topic {
  final int id, subjectId;
  final String title;
  final int? rotation;
  Topic.fromJson(Map<String, dynamic> j)
      : id = j['id'], subjectId = j['subjectId'], title = j['title'], rotation = j['rotation'];
  String get rotationName {
    const values = ['Generalidades', 'Primer rote', 'Segundo rote', 'Tercer rote', 'Cuarto rote', 'Quinto rote', 'Sexto rote', 'Séptimo rote'];
    return rotation == null ? 'Temario' : values[rotation!.clamp(0, 7).toInt()];
  }
}

class StudyResource {
  final String id, title, subtitle, category, kind, url, access, source, note;
  final List<String> headings;
  final int subjectId, topicId;
  StudyResource({required this.id, required this.title, this.subtitle = '', this.headings = const [], required this.category, required this.kind,
    required this.url, required this.access, required this.source, required this.note,
    required this.subjectId, required this.topicId});
  factory StudyResource.fromJson(Map<String, dynamic> j) => StudyResource(
    id: j['id']?.toString() ?? '', title: j['title']?.toString() ?? '',
    subtitle: j['subtitle']?.toString() ?? '',
    headings: (j['headings'] as List? ?? []).map((e) => e.toString()).toList(),
    category: j['category']?.toString() ?? '', kind: j['kind']?.toString() ?? 'web',
    url: j['url']?.toString() ?? '', access: j['access']?.toString() ?? 'free',
    source: j['source']?.toString() ?? 'Recurso', note: j['note']?.toString() ?? '',
    subjectId: (j['subjectId'] as num).toInt(), topicId: (j['topicId'] as num).toInt());
  Map<String, dynamic> toJson() => {'id':id,'title':title,'category':category,'kind':kind,
    'url':url,'access':access,'source':source,'note':note,'subtitle':subtitle,'headings':headings,'subjectId':subjectId,'topicId':topicId};
}

class FlashcardData {
  final int id, topicId;
  final String question, answer;
  FlashcardData.fromJson(Map<String, dynamic> j): id=j['id'], topicId=j['topicId'],question=j['question'],answer=j['answer'];
}

const resourceCategories = [
  'Libros oficiales y bibliografía', 'Resúmenes y apuntes',
  'Bancos de preguntas', 'Diapositivas', 'Exámenes pasados',
  'Videoclases', 'Flashcards', 'Extras',
];
const resourceIcons = <IconData>[
  Icons.menu_book_rounded, Icons.description_rounded, Icons.quiz_rounded,
  Icons.slideshow_rounded, Icons.fact_check_rounded, Icons.ondemand_video_rounded,
  Icons.style_rounded, Icons.auto_awesome_rounded,
];
const roteColors = <Color>[
  Colors.white, Color(0xFFE53935), Color(0xFFFACC15), Color(0xFF1976D2),
  Color(0xFFF57C00), Color(0xFF2E7D32), Color(0xFF7B1FA2), Color(0xFFB388FF),
];
