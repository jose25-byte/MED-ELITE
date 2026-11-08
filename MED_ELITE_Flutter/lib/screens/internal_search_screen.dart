import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../main.dart';
import '../services/internal_search_service.dart';

class InternalSearchScreen extends StatefulWidget {
  final MedStore store;
  final int? initialSubject;
  final String initialQuery;
  const InternalSearchScreen({super.key, required this.store,
    this.initialSubject, this.initialQuery = ''});
  @override State<InternalSearchScreen> createState() => _InternalSearchScreenState();
}

class _InternalSearchScreenState extends State<InternalSearchScreen> {
  late final TextEditingController _controller;
  int _subject = 0;
  String _type = 'Todos';
  @override void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _subject = widget.initialSubject ?? 0;
    _controller.addListener(_onQuery);
  }
  void _onQuery() => setState(() {});
  @override void dispose() { _controller.removeListener(_onQuery); _controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final hits = InternalSearchService.search(subjects: widget.store.subjects,
      topics: widget.store.topics, resources: widget.store.resources, query: query,
      subjectId: _subject == 0 ? null : _subject, searchTopics: _type != 'Recursos',
      searchResources: _type != 'Temas');
    final matchedSubjects = hits.map((h) => h.subject.id).toSet().length;
    return Scaffold(appBar: AppBar(title: const Text('Buscador interno')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.manage_search, size: 27), SizedBox(width: 9),
              Expanded(child: Text('Encuentra un tema en toda la carrera',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)))]),
            SizedBox(height: 7),
            Text('Busca solo en títulos y subtítulos del temario y en capítulos de los libros que hayan sido catalogados.'),
          ])),
        const SizedBox(height: 17),
        TextField(controller: _controller, autofocus: widget.initialQuery.isNotEmpty,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
            hintText: 'Shock, diabetes, corazón, sepsis...',
            suffixIcon: query.isEmpty ? null : IconButton(
              tooltip: 'Borrar', onPressed: _controller.clear,
              icon: const Icon(Icons.close))),),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(key: ValueKey(_subject), value: _subject,
          isExpanded: true, decoration: const InputDecoration(labelText: 'Asignatura',
            prefixIcon: Icon(Icons.library_books)),
          items: [const DropdownMenuItem<int>(value: 0,
            child: Text('Todas las asignaturas (44)')),
            ...widget.store.subjects.map((s) => DropdownMenuItem<int>(value: s.id,
              child: Text('${s.id}. ${s.name}', overflow: TextOverflow.ellipsis)))],
          onChanged: (value) => setState(() => _subject = value ?? 0)),
        const SizedBox(height: 12),
        SegmentedButton<String>(showSelectedIcon: false,
          segments: const [ButtonSegment(value: 'Todos', label: Text('Todos')),
            ButtonSegment(value: 'Temas', label: Text('Temas')),
            ButtonSegment(value: 'Recursos', label: Text('Libros / archivos'))],
          selected: {_type}, onSelectionChanged: (s) => setState(() => _type = s.first)),
        const SizedBox(height: 16),
        if (query.isEmpty) ...[
          const Text('Ejemplo de búsqueda', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ActionChip(avatar: const Icon(Icons.bolt), label: const Text('Buscar: shock'),
            onPressed: () => _controller.text = 'shock'),
          const SizedBox(height: 15),
          const Text('El índice de libros no descarga ni examina documentos privados. Se alimenta registrando sus títulos, subtítulos y encabezados en Administración.',
            style: TextStyle(fontSize: 12)),
        ] else ...[
          Text('${hits.length} coincidencias • $matchedSubjects asignaturas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (hits.isEmpty) const Padding(padding: EdgeInsets.all(22),
            child: Text('Sin resultados en los títulos catalogados. Para buscar dentro de libros, registra primero sus índices de capítulos.')),
          ...hits.map((hit) => Card(margin: const EdgeInsets.only(top: 8),
            child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              leading: Container(width: 44, height: 44, alignment: Alignment.center,
                decoration: BoxDecoration(color: hit.subject.accent,
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(hit.isTopic ? Icons.topic_outlined : Icons.menu_book_outlined,
                  color: hit.subject.accent.computeLuminance() > .47 ? Colors.black : Colors.white)),
              title: Text(hit.matchedText, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 5), Text('${hit.subject.shortName} · Tema ${hit.topic.id}'),
                Text(hit.field, style: Theme.of(context).textTheme.labelSmall),
                if (hit.resource != null) Text('Archivo: ${hit.resource!.title}',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => hit.isTopic
                  ? TopicDetailScreen(store: widget.store, subject: hit.subject, topic: hit.topic)
                  : ResourceViewerScreen(resource: hit.resource!))),
            ))),
        ],
      ]));
  }
}
