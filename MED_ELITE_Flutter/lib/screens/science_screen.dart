import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../state.dart';
import '../services/scientific_service.dart';

class ScienceScreen extends StatefulWidget {
  final MedStore store;
  final int initialSubject;
  final int? initialTopic;
  const ScienceScreen({super.key,required this.store,this.initialSubject=1,this.initialTopic});
  @override State<ScienceScreen> createState()=>_ScienceScreenState();
}
class _ScienceScreenState extends State<ScienceScreen> {
  final _query=TextEditingController();
  int _subject=1;
  int _topic=0;
  String _language='Todos';
  DateTimeRange? _range;
  bool _loading=false;
  String? _error;
  ScientificSearchResult? _result;
  final _languages={'Todos':'Todos', 'Inglés':'eng','Español':'spa','Portugués':'por','Alemán':'ger',
    'Francés':'fre','Italiano':'ita','Japonés':'jpn','Chino':'chi','Ruso':'rus'};
  @override void initState(){super.initState();_subject=widget.initialSubject;_topic=widget.initialTopic??0;}
  @override void dispose(){_query.dispose();super.dispose();}
  Future<void> _search() async {
    if(_range!=null && _range!.start.isAfter(_range!.end)) return;
    FocusScope.of(context).unfocus();setState((){_loading=true;_error=null;_result=null;});
    try {
      final r=await ScientificService.search(subject:widget.store.subject(_subject),
        topic:_topic==0?null:widget.store.topic(_topic),keywords:_query.text,
        language:_language,from:_range?.start,to:_range?.end);
      if(mounted)setState(()=>_result=r);
    } catch(e) {if(mounted)setState(()=>_error='$e');}
    finally {if(mounted)setState(()=>_loading=false);}
  }
  @override Widget build(BuildContext context) {
    final color=widget.store.subject(_subject).accent;
    final topics=widget.store.topicsFor(_subject);
    final fmt=(DateTime d)=>'${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
    return Scaffold(appBar:AppBar(title:const Text('Investigación científica')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),
        gradient:const LinearGradient(colors:[Color(0xFF8A1626),Color(0xFFCF3B45)])),
        child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Icon(Icons.science_outlined,color:Colors.white,size:28),SizedBox(width:10),
            Expanded(child:Text('Explorador de artículos',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)))]),
          SizedBox(height:8),Text('Busca literatura biomédica real mediante Europe PMC. Filtra por asignatura, tema, idioma y fechas.',
            style:TextStyle(color:Colors.white,height:1.4)),
        ])),const SizedBox(height:18),
      DropdownButtonFormField<int>(value:_subject,isExpanded:true,decoration:const InputDecoration(labelText:'Asignatura',border:OutlineInputBorder(),prefixIcon:Icon(Icons.school_outlined)),
        items:widget.store.subjects.map((s)=>DropdownMenuItem(value:s.id,child:Text('${s.id}. ${s.name}',overflow:TextOverflow.ellipsis))).toList(),
        onChanged:(v)=>setState((){_subject=v??1;_topic=0;_result=null;})),const SizedBox(height:12),
      DropdownButtonFormField<int>(key:ValueKey(_subject),value:_topic,isExpanded:true,
        decoration:const InputDecoration(labelText:'Tema del temario (opcional)',border:OutlineInputBorder(),prefixIcon:Icon(Icons.format_list_numbered)),
        items:[const DropdownMenuItem<int>(value:0,child:Text('Todos los temas')),...topics.map((t)=>DropdownMenuItem<int>(value:t.id,child:Text('${t.id}. ${t.title}',overflow:TextOverflow.ellipsis)))],
        onChanged:(v)=>setState((){_topic=v??0;_result=null;})),const SizedBox(height:12),
      TextField(controller:_query,textInputAction:TextInputAction.search,onSubmitted:(_)=>_search(),
        decoration:InputDecoration(labelText:'Palabras clave (opcional)',hintText:'Ej.: upper limb osteology',
          border:const OutlineInputBorder(),prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(icon:const Icon(Icons.clear),onPressed:()=>_query.clear()))),
      const SizedBox(height:8),const Text('Utiliza preferentemente términos científicos en inglés. Si escribes palabras clave, se combinan con el área médica elegida; sin palabras clave se busca por tema o asignatura.',
        style:TextStyle(fontSize:12,color:Colors.grey)),const SizedBox(height:14),
      Row(children:[Expanded(child:DropdownButtonFormField<String>(value:_language,isExpanded:true,
        decoration:const InputDecoration(labelText:'Idioma',border:OutlineInputBorder(),prefixIcon:Icon(Icons.language)),
        items:_languages.entries.map((e)=>DropdownMenuItem(value:e.value,child:Text(e.key))).toList(),
        onChanged:(v)=>setState(()=>_language=v??'Todos'))),const SizedBox(width:10),
        Expanded(child:OutlinedButton.icon(icon:const Icon(Icons.date_range),onPressed:() async {
          final today=DateTime.now();
          final r=await showDateRangePicker(context:context,firstDate:DateTime(1900),lastDate:today,
            initialDateRange:_range,helpText:'Intervalo de publicación');
          if(r!=null)setState(()=>_range=r);
        },label:Text(_range==null?'Fechas': '${fmt(_range!.start)} – ${fmt(_range!.end)}',overflow:TextOverflow.ellipsis),
          style:OutlinedButton.styleFrom(minimumSize:const Size(0,57))))]),
      if(_range!=null)Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:()=>setState(()=>_range=null),
        icon:const Icon(Icons.close,size:16),label:const Text('Quitar fechas'))),
      const SizedBox(height:12),FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:color==Colors.black?const Color(0xFFAD1E32):color,
        foregroundColor:color.computeLuminance()>0.65?Colors.black:Colors.white,minimumSize:const Size.fromHeight(52)),
        onPressed:_loading?null:_search,icon:const Icon(Icons.manage_search),label:const Text('Buscar artículos')),
      const SizedBox(height:18),
      if(_loading)const Center(child:Padding(padding:EdgeInsets.all(20),child:CircularProgressIndicator())),
      if(_error!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        const Icon(Icons.wifi_off_rounded,size:36),const SizedBox(height:8),Text('No fue posible obtener resultados: $_error',textAlign:TextAlign.center),
        TextButton(onPressed:_search,child:const Text('Reintentar'))]))),
      if(_result!=null)...[
        Text('${_result!.total} resultados en el índice consultado',style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:5),Text('Consulta: ${_result!.finalQuery}',style:Theme.of(context).textTheme.bodySmall),
        const SizedBox(height:12),
        if(_result!.articles.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('Sin resultados. Prueba otras palabras clave, un idioma diferente o amplía el rango de fechas.'))),
        for(final a in _result!.articles)Card(margin:const EdgeInsets.only(bottom:10),child:InkWell(borderRadius:BorderRadius.circular(12),
          onTap:()=>launchUrl(Uri.parse(a.link),mode:LaunchMode.externalApplication),
          child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(a.title,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:15)),const SizedBox(height:6),
            Text(a.authors,maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.bodySmall),
            const SizedBox(height:5),Text('${a.journal.isEmpty?'Europe PMC':a.journal}  •  ${a.date}',style:Theme.of(context).textTheme.labelSmall),
            if(a.abstractText.isNotEmpty)...[const SizedBox(height:7),Text(a.abstractText,maxLines:3,overflow:TextOverflow.ellipsis)],
            const SizedBox(height:10),Row(children:[const Icon(Icons.open_in_new,size:16),const SizedBox(width:5),
              Text(a.doi.isNotEmpty?'Ver artículo / DOI':'Abrir registro bibliográfico',style:TextStyle(color:color,fontWeight:FontWeight.w600))]),
          ])))),
        const SizedBox(height:18),const Text('Los resultados se recuperan en tiempo real de Europe PMC. La cobertura no es exhaustiva ni constituye una evaluación de la calidad de cada artículo.',
          style:TextStyle(fontSize:12,color:Colors.grey)),
      ],
    ]));
  }
}
