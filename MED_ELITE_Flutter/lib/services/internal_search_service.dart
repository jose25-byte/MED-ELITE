import '../models.dart';

/// An index of metadata, never a full-text search of PDFs or Drive files.
/// Topic titles and resource titles/subtitles/chapter headings are searchable.
class InternalSearchHit {
  final Subject subject;
  final Topic topic;
  final StudyResource? resource;
  final String matchedText;
  final String field;
  final int score;

  const InternalSearchHit({required this.subject, required this.topic,
    required this.resource, required this.matchedText, required this.field,
    required this.score});
  bool get isTopic => resource == null;
}

class InternalSearchService {
  static String normalize(String value) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ';
    const to   = 'aaaaaeeeeiiiiooooouuuuncAAAAAEEEEIIIIOOOOOUUUUNC';
    final out = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final pos = from.indexOf(char);
      out.write(pos >= 0 ? to[pos].toLowerCase() : char.toLowerCase());
    }
    return out.toString().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool matches(String text, String query) {
    final words = normalize(query).split(' ').where((w) => w.isNotEmpty);
    final normalized = normalize(text);
    return words.isNotEmpty && words.every(normalized.contains);
  }

  static List<InternalSearchHit> search({required List<Subject> subjects,
    required List<Topic> topics, required List<StudyResource> resources,
    required String query, int? subjectId, bool searchTopics = true,
    bool searchResources = true}) {
    if (normalize(query).isEmpty) return [];
    final subjectMap = {for (final s in subjects) s.id: s};
    final topicMap = {for (final t in topics) t.id: t};
    final hits = <InternalSearchHit>[];
    if (searchTopics) {
      for (final topic in topics) {
        if (subjectId != null && topic.subjectId != subjectId) continue;
        if (!matches(topic.title, query)) continue;
        final subject = subjectMap[topic.subjectId];
        if (subject == null) continue;
        hits.add(InternalSearchHit(subject: subject, topic: topic,
          resource: null, matchedText: topic.title, field: 'Título del tema',
          score: normalize(topic.title) == normalize(query) ? 110 : 90));
      }
    }
    if (searchResources) {
      for (final resource in resources) {
        if (subjectId != null && resource.subjectId != subjectId) continue;
        final subject = subjectMap[resource.subjectId];
        final topic = topicMap[resource.topicId];
        if (subject == null || topic == null) continue;
        // Only explicitly cataloged metadata, not notes, abstracts or PDF body text.
        final searchable = <(String, String, int)>[
          (resource.title, 'Título del recurso', 85),
          (resource.subtitle, 'Subtítulo del recurso', 75),
          for (final heading in resource.headings) (heading, 'Capítulo / subtítulo del libro', 70),
        ];
        for (final item in searchable) {
          if (!matches(item.$1, query)) continue;
          hits.add(InternalSearchHit(subject: subject, topic: topic,
            resource: resource, matchedText: item.$1, field: item.$2,
            score: normalize(item.$1) == normalize(query) ? item.$3 + 10 : item.$3));
        }
      }
    }
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final bySubject = a.subject.id.compareTo(b.subject.id);
      if (bySubject != 0) return bySubject;
      return a.topic.id.compareTo(b.topic.id);
    });
    return hits;
  }
}
