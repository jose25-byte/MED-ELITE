import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'models.dart';
import 'state.dart';
import 'screens/science_screen.dart';
import 'screens/internal_search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store=MedStore();
  await store.load();
  runApp(MedEliteApp(store:store));
}

class MedEliteApp extends StatelessWidget {
  final MedStore store;
  const MedEliteApp({super.key,required this.store});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation:store,builder:(context,_)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'MED ELITE',
    themeMode:store.darkMode?ThemeMode.dark:ThemeMode.light,
    theme:_theme(Brightness.light),darkTheme:_theme(Brightness.dark),
    home:MainShell(store:store),
  ));
  ThemeData _theme(Brightness brightness){
    final scheme=ColorScheme.fromSeed(seedColor:const Color(0xFFC52F42),brightness:brightness);
    return ThemeData(useMaterial3:true,brightness:brightness,colorScheme:scheme,
      scaffoldBackgroundColor:brightness==Brightness.light?const Color(0xFFF7F8FB):const Color(0xFF101219),
      appBarTheme:const AppBarTheme(centerTitle:false,elevation:0),
      cardTheme:CardThemeData(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),
      inputDecorationTheme:InputDecorationTheme(border:OutlineInputBorder(borderRadius:BorderRadius.circular(13)),
        contentPadding:const EdgeInsets.symmetric(vertical:15,horizontal:14)),
    );
  }
}

void push(BuildContext context,Widget page){Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>page));}
const brand=Color(0xFFC52F42);

class MainShell extends StatefulWidget {
  final MedStore store;
  const MainShell({super.key,required this.store});
  @override State<MainShell> createState()=>_MainShellState();
}
class _MainShellState extends State<MainShell> {
  int _index=0;
  @override Widget build(BuildContext context){
    final pages=[HomeScreen(store:widget.store),SubjectsScreen(store:widget.store),
      InternalSearchScreen(store:widget.store),ScienceScreen(store:widget.store),ProfileScreen(store:widget.store)];
    return Scaffold(body:IndexedStack(index:_index,children:pages),
      bottomNavigationBar:NavigationBar(selectedIndex:_index,height:73,onDestinationSelected:(i)=>setState(()=>_index=i),
        destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Inicio'),
          NavigationDestination(icon:Icon(Icons.menu_book_outlined),selectedIcon:Icon(Icons.menu_book),label:'Materias'),
          NavigationDestination(icon:Icon(Icons.search_outlined),selectedIcon:Icon(Icons.search),label:'Buscar'),
          NavigationDestination(icon:Icon(Icons.science_outlined),selectedIcon:Icon(Icons.science),label:'Ciencia'),
          NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Perfil')]));
  }
}

class HomeScreen extends StatelessWidget {
  final MedStore store;
  const HomeScreen({super.key,required this.store});
  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(appBar:AppBar(title:const Text('MED ELITE',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.2)),
        actions:[IconButton(tooltip:'Configuración',onPressed:()=>push(context,SettingsScreen(store:store)),icon:const Icon(Icons.tune)),
          const SizedBox(width:8)]),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,26),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF8E172B),Color(0xFFCF4051)]),
        borderRadius:BorderRadius.circular(26)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Row(children:[Icon(Icons.health_and_safety_outlined,color:Colors.white),SizedBox(width:7),
            Text('BIBLIOTECA ACADÉMICA',style:TextStyle(color:Color(0xFFFFCCD4),fontSize:11,letterSpacing:1.3,fontWeight:FontWeight.w700))]),
          const SizedBox(height:18),const Text('Tu medicina,\na tu ritmo.',style:TextStyle(color:Colors.white,fontSize:31,fontWeight:FontWeight.w800,height:1.1)),
          const SizedBox(height:8),const Text('Estudia, investiga y organiza tus recursos en un solo lugar.',style:TextStyle(color:Colors.white70)),
          const SizedBox(height:16),Wrap(spacing:8,runSpacing:8,children:[
            _pill('44 asignaturas'),_pill('1.337 temas'),_pill('Investigación real'),
          ]),const SizedBox(height:18),
          FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:const Color(0xFF8E172B)),
            onPressed:()=>push(context,SubjectDetailScreen(store:store,subject:store.subject(1))),
            icon:const Icon(Icons.arrow_forward),label:const Text('Explorar Anatomía')),
        ])),const SizedBox(height:20),
      _section(context,'Accesos rápidos','Todo para tu formación'),const SizedBox(height:11),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.55,
        mainAxisSpacing:10,crossAxisSpacing:10,children:[
        _quick(context,Icons.style_rounded,'Flashcards','Memoriza mejor',const Color(0xFF008F83),()=>push(context,FlashcardsScreen(store:store))),
        _quick(context,Icons.search_rounded,'Buscar temas','Títulos y capítulos',const Color(0xFF2F6BB4),()=>push(context,InternalSearchScreen(store:store))),
        _quick(context,Icons.widgets_rounded,'Módulos','Herramientas extras',const Color(0xFF8153B5),()=>push(context,ModulesScreen(store:store))),
        _quick(context,Icons.workspace_premium_rounded,'Membresías','Planes de acceso',const Color(0xFFC08428),()=>push(context,MembershipScreen(store:store))),
      ]),const SizedBox(height:21),
      _section(context,'Tu primera asignatura','Biblioteca lista para explorar'),const SizedBox(height:10),
      SubjectTile(subject:store.subject(1),onTap:()=>push(context,SubjectDetailScreen(store:store,subject:store.subject(1)))),
      const SizedBox(height:20),
      Card(color:dark?const Color(0xFF1A2730):const Color(0xFFEAF5FB),child:Padding(padding:const EdgeInsets.all(16),
        child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.info_outline,color:Color(0xFF34749A)),
          const SizedBox(width:10),Expanded(child:Text('Versión de prueba: las membresías y cuentas son simuladas. Los artículos se consultan en vivo; los archivos de Drive se añaden desde Administración.',
            style:Theme.of(context).textTheme.bodySmall))]))),
    ]));
  }
  Widget _pill(String label)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:0.14),borderRadius:BorderRadius.circular(30)),
    child:Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600,color:Colors.white)));
  Widget _quick(BuildContext ctx,IconData icon,String title,String subtitle,Color color,VoidCallback onTap){
    return Card(margin:EdgeInsets.zero,child:InkWell(borderRadius:BorderRadius.circular(16),onTap:onTap,
      child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:color,size:26),const SizedBox(height:8),
          Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),
          Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(ctx).textTheme.bodySmall)]))));
  }
}
Widget _section(BuildContext context,String title,String subtitle)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text(title,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),
  Text(subtitle,style:Theme.of(context).textTheme.bodySmall)]);

class SubjectsScreen extends StatefulWidget {
  final MedStore store;
  const SubjectsScreen({super.key,required this.store});
  @override State<SubjectsScreen> createState()=>_SubjectsScreenState();
}
class _SubjectsScreenState extends State<SubjectsScreen>{
  String query='';int year=0;
  @override Widget build(BuildContext context){
    final filtered=widget.store.subjects.where((s)=>(year==0||s.year==year)&&
      ('${s.id} ${s.name} ${s.shortName}'.toLowerCase().contains(query.toLowerCase()))).toList();
    return Scaffold(appBar:AppBar(title:const Text('44 asignaturas'),actions:[IconButton(icon:const Icon(Icons.settings_outlined),
      onPressed:()=>push(context,SettingsScreen(store:widget.store)))]),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(
          prefixIcon:Icon(Icons.search),hintText:'Buscar una asignatura...',border:OutlineInputBorder())),const SizedBox(height:12),
        SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[0,1,2,3,4,5].map((y)=>Padding(padding:const EdgeInsets.only(right:6),
          child:ChoiceChip(label:Text(y==0?'Todas':'$y.º año'),selected:year==y,onSelected:(_)=>setState(()=>year=y)))).toList())),
        const SizedBox(height:15),Text('${filtered.length} materias • ${widget.store.topics.length} temas en el temario',style:Theme.of(context).textTheme.bodySmall),
        const SizedBox(height:8),for(final s in filtered)Padding(padding:const EdgeInsets.only(bottom:9),child:SubjectTile(
          subject:s,onTap:()=>push(context,SubjectDetailScreen(store:widget.store,subject:s)))),
      ]));
  }
}
class SubjectTile extends StatelessWidget {
  final Subject subject;final VoidCallback onTap;
  const SubjectTile({super.key,required this.subject,required this.onTap});
  @override Widget build(BuildContext context){
    final color=subject.accent;
    final whiteText=color.computeLuminance()<0.47;
    return Card(margin:EdgeInsets.zero,child:InkWell(borderRadius:BorderRadius.circular(16),onTap:onTap,
      child:Row(children:[Container(height:87,width:11,decoration:BoxDecoration(color:color,
        borderRadius:const BorderRadius.horizontal(left:Radius.circular(15)))),
        const SizedBox(width:14),Container(width:44,height:44,alignment:Alignment.center,
          decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(13),border:Border.all(color:Colors.black12)),
          child:Text('${subject.id}',style:TextStyle(color:whiteText?Colors.white:Colors.black,fontWeight:FontWeight.w800))),
        const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(subject.name,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:14)),const SizedBox(height:3),
          Text('${subject.year}.º año • ${subject.count} temas',style:Theme.of(context).textTheme.bodySmall)])),
        const Icon(Icons.chevron_right_rounded),const SizedBox(width:10)])));
  }
}

class SubjectDetailScreen extends StatefulWidget{
  final MedStore store;final Subject subject;
  const SubjectDetailScreen({super.key,required this.store,required this.subject});
  @override State<SubjectDetailScreen> createState()=>_SubjectDetailScreenState();
}
class _SubjectDetailScreenState extends State<SubjectDetailScreen>{
  String filter='';
  @override Widget build(BuildContext context){
    final s=widget.subject;
    final dark=Theme.of(context).brightness==Brightness.dark;
    final all=widget.store.topicsFor(s.id).where((t)=>'${t.id} ${t.title}'.toLowerCase().contains(filter.toLowerCase())).toList();
    final accent=s.accent==Colors.black?const Color(0xFF6A6F7F):s.accent;
    final grouped=<int,List<Topic>>{};
    for(final t in all){grouped.putIfAbsent(t.rotation??-1,()=>[]).add(t);}
    return Scaffold(appBar:AppBar(title:Text(s.shortName),actions:[IconButton(tooltip:'Buscar artículos',onPressed:()=>push(context,
      ScienceScreen(store:widget.store,initialSubject:s.id)),icon:const Icon(Icons.science_outlined))]),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,6,16,28),children:[
        Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:dark?Color.lerp(const Color(0xFF171922),accent,0.3):Color.lerp(Colors.white,accent,0.18),borderRadius:BorderRadius.circular(22)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[Container(width:8,height:51,decoration:BoxDecoration(color:s.accent,borderRadius:BorderRadius.circular(10))),
              const SizedBox(width:12),Expanded(child:Text(s.name,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w800)))]),
            const SizedBox(height:12),Text('${s.count} temas numerados  •  ${s.year}.º año  •  Código de color original del temario',
              style:Theme.of(context).textTheme.bodySmall),
            const SizedBox(height:14),Wrap(spacing:7,runSpacing:7,children:[
              ActionChip(avatar:const Icon(Icons.style,size:18),label:const Text('Flashcards'),onPressed:()=>push(context,FlashcardsScreen(store:widget.store))),
              ActionChip(avatar:const Icon(Icons.science,size:18),label:const Text('Artículos'),onPressed:()=>push(context,
                ScienceScreen(store:widget.store,initialSubject:s.id))),
              ActionChip(avatar:const Icon(Icons.search,size:18),label:const Text('Buscar títulos'),onPressed:()=>push(context,InternalSearchScreen(store:widget.store,initialSubject:s.id))),
            ])])),
        if(s.id==1)...[const SizedBox(height:15),const Text('Rotaciones de Anatomía',style:TextStyle(fontWeight:FontWeight.w700)),
          const SizedBox(height:8),SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
            for(int i=0;i<=7;i++)Padding(padding:const EdgeInsets.only(right:6),child:Chip(
              avatar:CircleAvatar(backgroundColor:roteColors[i],radius:7),
              label:Text(i==0?'General.':'Rote $i',style:const TextStyle(fontSize:11))))]))],
        const SizedBox(height:16),TextField(onChanged:(v)=>setState(()=>filter=v),decoration:const InputDecoration(
          prefixIcon:Icon(Icons.search),hintText:'Buscar entre los temas...',border:OutlineInputBorder())),
        const SizedBox(height:15),
        for(final entry in grouped.entries)...[
          Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Row(children:[
            Text(s.id==1?(entry.key==0?'GENERALIDADES':'${entry.key}.º ROTE'):'TEMARIO',
              style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),
            const SizedBox(width:8),Expanded(child:Divider(color:accent.withValues(alpha:0.35)))])),
          for(final t in entry.value)Padding(padding:const EdgeInsets.only(bottom:8),child:TopicTile(topic:t,subject:s,
            onTap:()=>push(context,TopicDetailScreen(store:widget.store,subject:s,topic:t)))),
        ],
        if(all.isEmpty)const Center(child:Padding(padding:EdgeInsets.all(30),child:Text('No hay temas con ese criterio.'))),
      ]));
  }
}
class TopicTile extends StatelessWidget{
  final Topic topic; final Subject subject;final VoidCallback onTap;
  const TopicTile({super.key,required this.topic,required this.subject,required this.onTap});
  @override Widget build(BuildContext context){
    final accent=subject.id==1?roteColors[(topic.rotation??0).clamp(0,7).toInt()]:subject.accent;
    final isWhite=subject.id==1&&topic.rotation==0;
    final textColor=isWhite?Colors.black:(accent.computeLuminance()<0.44?Colors.white:Colors.black);
    return Card(margin:EdgeInsets.zero,color:subject.id==1?accent:null,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),
      child:Row(children:[Container(width:62,alignment:Alignment.center,padding:const EdgeInsets.symmetric(vertical:18),
        decoration:BoxDecoration(color:accent,borderRadius:const BorderRadius.horizontal(left:Radius.circular(15)),
          border:Border.all(color:Colors.black12)),
        child:Text('${topic.id}',style:TextStyle(fontWeight:FontWeight.w800,color:textColor))),
        const SizedBox(width:12),Expanded(child:Text(topic.title,style:TextStyle(fontSize:13,fontWeight:FontWeight.w700,color:subject.id==1?textColor:null))),
        Icon(Icons.chevron_right,color:subject.id==1?textColor:null),const SizedBox(width:8)])));
  }
}

class TopicDetailScreen extends StatelessWidget {
  final MedStore store;final Subject subject;final Topic topic;
  const TopicDetailScreen({super.key,required this.store,required this.subject,required this.topic});
  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(appBar:AppBar(title:Text('Tema ${topic.id}'),actions:[IconButton(icon:const Icon(Icons.science),
      onPressed:()=>push(context,ScienceScreen(store:store,initialSubject:subject.id,initialTopic:topic.id)))]),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),
          color:Color.lerp(dark?const Color(0xFF202126):Colors.white,subject.accent,dark ? 0.22 : 0.12)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(subject.name.toUpperCase(),style:TextStyle(color:dark?Colors.white70:Colors.black54,fontSize:11,fontWeight:FontWeight.w800,letterSpacing:1.1)),
            const SizedBox(height:7),Text('${topic.id}. ${topic.title}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:21)),
            const SizedBox(height:8),Text(topic.rotationName,style:Theme.of(context).textTheme.bodySmall)])),
        const SizedBox(height:18),_section(context,'Material de estudio','Selecciona un tipo de recurso'),const SizedBox(height:12),
        GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:resourceCategories.length,
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:11,mainAxisSpacing:11,childAspectRatio:1.3),
          itemBuilder:(ctx,i){
            final mix=(i+1)/10;
            final bg=Color.lerp(dark?const Color(0xFF1A1D24):Colors.white,subject.accent,dark?0.18+mix*0.25:0.13+mix*0.25)!;
            final amount=store.resourcesFor(subject.id,topic.id,resourceCategories[i]).length;
            return Material(color:bg,borderRadius:BorderRadius.circular(17),child:InkWell(borderRadius:BorderRadius.circular(17),
              onTap:()=>resourceCategories[i]=='Flashcards'
                ?push(context,FlashcardsScreen(store:store,topicId:topic.id))
                :push(context,ResourceListScreen(store:store,subject:subject,topic:topic,category:resourceCategories[i])),
              child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,
                mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                  Icon(resourceIcons[i],color:dark?Colors.white:subject.accent==Colors.black?Colors.black:subject.accent),
                  Text(resourceCategories[i],maxLines:2,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
                  Text(resourceCategories[i]=='Flashcards'?'Repaso activo':'$amount recursos',style:Theme.of(context).textTheme.bodySmall),
                ]))));
          }),
        const SizedBox(height:16),OutlinedButton.icon(onPressed:()=>push(context,
          ScienceScreen(store:store,initialSubject:subject.id,initialTopic:topic.id)),
          icon:const Icon(Icons.science_outlined),label:const Text('Buscar artículos científicos sobre este tema')),
      ]));
  }
}

class ResourceListScreen extends StatelessWidget {
  final MedStore store;final Subject subject;final Topic topic;final String category;
  const ResourceListScreen({super.key,required this.store,required this.subject,required this.topic,required this.category});
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:store,builder:(context,_){
    final items=store.resourcesFor(subject.id,topic.id,category);
    return Scaffold(appBar:AppBar(title:Text(category)),body:ListView(padding:const EdgeInsets.all(16),children:[
      Text('${topic.id}. ${topic.title}',style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:12),if(items.isEmpty)Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[
        const Icon(Icons.folder_open_outlined,size:43),const SizedBox(height:10),
        const Text('No hay archivos cargados en esta categoría.',textAlign:TextAlign.center),const SizedBox(height:8),
        const Text('Añade enlaces individuales de Google Drive u otros recursos autorizados desde Administración.',textAlign:TextAlign.center),
        const SizedBox(height:12),OutlinedButton.icon(onPressed:()=>push(context,AdminScreen(store:store,initialSubject:subject.id,initialTopic:topic.id,initialCategory:category)),
          icon:const Icon(Icons.add),label:const Text('Agregar recurso'))]))),
      for(final r in items)Card(child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
        leading:CircleAvatar(backgroundColor:subject.accent.withValues(alpha:0.18),child:Icon(r.kind=='youtube'||r.kind=='video'?Icons.play_arrow:Icons.insert_drive_file,color:subject.accent==Colors.black?Colors.grey:subject.accent)),
        title:Text(r.title,style:const TextStyle(fontWeight:FontWeight.w700)),
        subtitle:Text('${r.source}  •  ${r.access=='free'?'Acceso abierto':'Acceso de prueba'}'),
        trailing:const Icon(Icons.chevron_right),onTap:()=>push(context,ResourceViewerScreen(resource:r)))),
      const SizedBox(height:12),FilledButton.tonalIcon(onPressed:()=>push(context,AdminScreen(store:store,initialSubject:subject.id,initialTopic:topic.id,initialCategory:category)),
        icon:const Icon(Icons.add_link),label:const Text('Registrar nuevo enlace')),
    ]));
  });
}

class ResourceViewerScreen extends StatefulWidget {
  final StudyResource resource;
  const ResourceViewerScreen({super.key,required this.resource});
  @override State<ResourceViewerScreen> createState()=>_ResourceViewerScreenState();
}
class _ResourceViewerScreenState extends State<ResourceViewerScreen>{
  WebViewController? _web;
  YoutubePlayerController? _youtube;
  VideoPlayerController? _video;
  String? _error;
  @override void initState(){super.initState();_init();}
  String? _youtubeId(String url){
    final u=Uri.tryParse(url);if(u==null)return null;
    if(u.host=='youtu.be')return u.pathSegments.isEmpty?null:u.pathSegments.first;
    if(u.host.endsWith('youtube.com')||u.host.endsWith('youtube-nocookie.com')){
      if(u.pathSegments.isNotEmpty&&u.pathSegments.first=='embed'&&u.pathSegments.length>1)return u.pathSegments[1];
      return u.queryParameters['v'];
    }
    return null;
  }
  void _init(){
    final r=widget.resource;
    try{
      if(r.kind=='youtube'){
        final id=_youtubeId(r.url);
        if(id==null||id.isEmpty){_error='La URL de YouTube no es válida.';return;}
        _youtube=YoutubePlayerController.fromVideoId(videoId:id,autoPlay:false,
          params:const YoutubePlayerParams(showFullscreenButton:true,playsInline:true));
      }else if(r.kind=='video'){
        _video=VideoPlayerController.networkUrl(Uri.parse(r.url))..initialize().then((_){if(mounted)setState((){});}).catchError((Object e){if(mounted)setState(()=>_error='No se pudo cargar el video: $e');});
      }else{
        var url=r.url;
        final match=RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
        if(match!=null&&Uri.parse(url).host.contains('drive.google.com')){
          url='https://drive.google.com/file/d/${match.group(1)}/preview';
        }
        _web=WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(NavigationDelegate(onWebResourceError:(e){
            if(e.isForMainFrame==true&&mounted)setState(()=>_error='El sitio no permite previsualización en la app. Utiliza Abrir origen.');
          }))..loadRequest(Uri.parse(url));
      }
    } catch(e){_error='$e';}
  }
  @override void dispose(){_youtube?.close();_video?.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final r=widget.resource;
    return Scaffold(appBar:AppBar(title:Text(r.title,maxLines:1,overflow:TextOverflow.ellipsis),actions:[
      IconButton(tooltip:'Abrir origen',icon:const Icon(Icons.open_in_browser),onPressed:()=>launchUrl(Uri.parse(r.url),mode:LaunchMode.externalApplication))]),
      body:Column(children:[
        if(_error!=null)Padding(padding:const EdgeInsets.all(14),child:Text(_error!,style:const TextStyle(color:Colors.red))),
        if(r.kind=='youtube'&&_youtube!=null)...[
          YoutubePlayer(controller:_youtube!),const Padding(padding:EdgeInsets.all(14),child:Text('YouTube integrado: solo para videos sin bloqueo de pago. Se respetan los controles oficiales del reproductor.')),
        ]else if(r.kind=='video'&&_video!=null)...[
          if(_video!.value.isInitialized)...[AspectRatio(aspectRatio:_video!.value.aspectRatio,child:VideoPlayer(_video!)),
            IconButton.filledTonal(icon:Icon(_video!.value.isPlaying?Icons.pause:Icons.play_arrow),onPressed:(){
              setState((){_video!.value.isPlaying?_video!.pause():_video!.play();});})]
          else const Padding(padding:EdgeInsets.all(22),child:CircularProgressIndicator()),
        ]else if(_web!=null)Expanded(child:WebViewWidget(controller:_web!)),
        if(_web==null&&_video==null&&_youtube==null)const Expanded(child:Center(child:Text('No se pudo abrir el recurso.'))),
        if(_web==null)Padding(padding:const EdgeInsets.all(14),child:FilledButton.tonalIcon(icon:const Icon(Icons.open_in_new),
          onPressed:()=>launchUrl(Uri.parse(r.url),mode:LaunchMode.externalApplication),label:const Text('Abrir página de origen'))),
      ]));
  }
}

// -------- Extras: flashcards, plans, settings, profile, administration --------

class FlashcardsScreen extends StatefulWidget {
  final MedStore store;
  final int? topicId;
  const FlashcardsScreen({super.key,required this.store,this.topicId});
  @override State<FlashcardsScreen> createState()=>_FlashcardsScreenState();
}
class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int index=0; bool showAnswer=false;
  @override Widget build(BuildContext context) {
    final cards=widget.store.flashcards.where((f)=>widget.topicId==null||f.topicId==widget.topicId).toList();
    return Scaffold(appBar:AppBar(title:const Text('Flashcards')),
      body:Padding(padding:const EdgeInsets.all(18),child:cards.isEmpty
        ?const Center(child:Text('Todavía no hay flashcards en este tema.'))
        :Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Text('Tarjeta ${index+1} de ${cards.length}',style:Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:13),LinearProgressIndicator(value:(index+1)/cards.length),
          const SizedBox(height:20),Expanded(child:Card(color:Theme.of(context).colorScheme.primaryContainer,
            child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>setState(()=>showAnswer=!showAnswer),
              child:Padding(padding:const EdgeInsets.all(25),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
                Icon(showAnswer?Icons.lightbulb_outline:Icons.psychology,size:42),const SizedBox(height:20),
                Text(showAnswer?'RESPUESTA':'PREGUNTA',style:const TextStyle(fontWeight:FontWeight.w800,letterSpacing:2)),
                const SizedBox(height:20),Text(showAnswer?cards[index].answer:cards[index].question,
                  textAlign:TextAlign.center,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w700)),
                const SizedBox(height:20),Text('Toca la tarjeta para ${showAnswer?'ver la pregunta':'revelar la respuesta'}',
                  textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall),
              ]))))),
          const SizedBox(height:16),Row(children:[Expanded(child:OutlinedButton.icon(
            onPressed:index==0?null:()=>setState((){index--;showAnswer=false;}),
            icon:const Icon(Icons.arrow_back),label:const Text('Anterior'))),
            const SizedBox(width:10),Expanded(child:FilledButton.icon(
              onPressed:()=>setState((){index=(index+1)%cards.length;showAnswer=false;}),
              icon:const Icon(Icons.arrow_forward),label:Text(index==cards.length-1?'Reiniciar':'Siguiente')))]),
          const SizedBox(height:18),
        ])));
  }
}

class ModulesScreen extends StatelessWidget {
  final MedStore store;
  const ModulesScreen({super.key,required this.store});
  @override Widget build(BuildContext context){
    final modules=<({String name,String detail,IconData icon,VoidCallback? action})>[
      (name:'Flashcards',detail:'Repaso activo — operativo con tarjetas de muestra',icon:Icons.style,
        action:()=>push(context,FlashcardsScreen(store:store))),
      (name:'Búsqueda por temas',detail:'Cruza asignaturas, títulos y capítulos catalogados',icon:Icons.manage_search,
        action:()=>push(context,InternalSearchScreen(store:store))),
      (name:'Buscador científico',detail:'Consulta Europe PMC con filtros',icon:Icons.science,
        action:()=>push(context,ScienceScreen(store:store))),
      (name:'Simulador de exámenes',detail:'Próxima fase',icon:Icons.assignment_turned_in_outlined,action:null),
      (name:'Atlas de Anatomía 3D',detail:'Módulo futuro',icon:Icons.view_in_ar,action:null),
      (name:'Casos clínicos',detail:'Módulo futuro',icon:Icons.medical_information_outlined,action:null),
      (name:'DLC y aplicaciones externas',detail:'Integraciones futuras',icon:Icons.extension_outlined,action:null),
    ];
    return Scaffold(appBar:AppBar(title:const Text('Centro de módulos')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        const Text('Funcionalidades y expansiones',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),
        const SizedBox(height:8),const Text('Los módulos marcados como futuros no están implementados en este prototipo.'),
        const SizedBox(height:14),for(final module in modules)Card(child:ListTile(
          leading:Icon(module.icon,color:Theme.of(context).colorScheme.primary,size:28),
          title:Text(module.name,style:const TextStyle(fontWeight:FontWeight.w700)),
          subtitle:Text(module.detail),
          trailing:module.action==null?const Icon(Icons.lock_clock_outlined):const Icon(Icons.chevron_right),
          onTap:module.action)),
      ]));
  }
}

class SettingsScreen extends StatelessWidget {
  final MedStore store;
  const SettingsScreen({super.key,required this.store});
  @override Widget build(BuildContext context){
    return Scaffold(appBar:AppBar(title:const Text('Configuración')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        const Text('Apariencia',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
        const SizedBox(height:12),Card(child:SwitchListTile(
          title:const Text('Modo oscuro'),subtitle:const Text('Fondo negro o blanco según tu preferencia'),
          secondary:Icon(store.darkMode?Icons.dark_mode:Icons.light_mode),value:store.darkMode,
          onChanged:store.setDark)),
        const SizedBox(height:18),const Text('MED ELITE v0.1',style:TextStyle(fontWeight:FontWeight.w700)),
        const SizedBox(height:6),const Text('Los datos del prototipo, recursos añadidos y planes simulados se almacenan en este dispositivo. No están sincronizados entre usuarios.'),
      ]));
  }
}

class MembershipScreen extends StatelessWidget {
  final MedStore store;
  const MembershipScreen({super.key,required this.store});
  Future<void> choose(BuildContext context,String value) async {
    await store.setMembership(value);
    if(!context.mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Plan de demostración activado: $value. No se realizó ningún cobro.')));
  }
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:store,builder:(context,_){
    final plans=<({String title,String detail,IconData icon})>[
      (title:'Básico · mensual',detail:'Biblioteca básica y resúmenes',icon:Icons.menu_book_outlined),
      (title:'Intermedio · mensual',detail:'Más archivos, diapositivas y evaluaciones',icon:Icons.school_outlined),
      (title:'Completo · mensual',detail:'Materiales, simuladores y video alojado legalmente',icon:Icons.workspace_premium_outlined),
      (title:'Acceso vitalicio · pago único',detail:'Condiciones definitivas por definir',icon:Icons.all_inclusive),
    ];
    return Scaffold(appBar:AppBar(title:const Text('Membresías')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        const Text('Planes de MED ELITE',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
        const SizedBox(height:5),const Text('SIMULACIÓN: ningún botón cobra dinero, concede acceso real ni modifica una cuenta en un servidor.'),
        const SizedBox(height:12),Card(color:Theme.of(context).colorScheme.primaryContainer,
          child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Estado de demostración',style:TextStyle(fontWeight:FontWeight.w800)),
            const SizedBox(height:5),Text(store.membership,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w700)),
            if(store.trialEnds!=null&&store.membership=='Prueba gratuita')Text('Vence: ${store.trialEnds!.day}/${store.trialEnds!.month}/${store.trialEnds!.year}'),
          ]))),const SizedBox(height:12),
        OutlinedButton.icon(onPressed:store.trialUsed?null:()=>choose(context,'Prueba gratuita'),
          icon:const Icon(Icons.card_giftcard),label:Text(store.trialUsed?'Prueba gratuita ya utilizada en este dispositivo':'Simular 7 días de prueba gratuita')),
        const SizedBox(height:12),for(final plan in plans)Card(child:Padding(
          padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(children:[Icon(plan.icon,size:28),const SizedBox(width:10),
              Expanded(child:Text(plan.title,style:const TextStyle(fontWeight:FontWeight.w800)))]),
            const SizedBox(height:6),Text(plan.detail),const SizedBox(height:12),
            FilledButton.tonal(onPressed:()=>choose(context,plan.title),child:const Text('Activar simulación')),
          ]))),
        const SizedBox(height:14),const Text('Producción: se requerirán Google Play Billing, Apple In-App Purchase y verificación de compras en servidor. La prueba se vinculará a una cuenta real.'),
      ]));
  });
}

class ProfileScreen extends StatelessWidget {
  final MedStore store;
  const ProfileScreen({super.key,required this.store});
  @override Widget build(BuildContext context) => Scaffold(appBar:AppBar(title:const Text('Perfil')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(20),child:Row(children:[
        CircleAvatar(radius:31,backgroundColor:Theme.of(context).colorScheme.primaryContainer,
          child:const Icon(Icons.person,size:36)),const SizedBox(width:13),
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Usuario de demostración',style:TextStyle(fontWeight:FontWeight.w800,fontSize:18)),
          Text('El inicio de sesión con Google aún no está conectado.'),
        ]))]))),const SizedBox(height:12),
      Card(child:ListTile(leading:const Icon(Icons.workspace_premium),title:const Text('Mi membresía'),
        subtitle:Text(store.membership),trailing:const Icon(Icons.chevron_right),
        onTap:()=>push(context,MembershipScreen(store:store)))),
      Card(child:ListTile(leading:const Icon(Icons.settings),title:const Text('Configuración'),
        trailing:const Icon(Icons.chevron_right),onTap:()=>push(context,SettingsScreen(store:store)))),
      Card(child:ListTile(leading:const Icon(Icons.admin_panel_settings),title:const Text('Administración local (demo)'),
        subtitle:const Text('Añadir enlaces, títulos, subtítulos e índices de libros'),
        trailing:const Icon(Icons.chevron_right),onTap:()=>push(context,AdminScreen(store:store)))),
      Card(child:ListTile(leading:const Icon(Icons.widgets),title:const Text('Otras aplicaciones y DLC'),
        trailing:const Icon(Icons.chevron_right),onTap:()=>push(context,ModulesScreen(store:store)))),
      const SizedBox(height:12),const Text('IMPORTANTE: En esta demostración cualquiera que use el dispositivo puede abrir Administración. Antes de publicar se implementarán roles y controles de acceso en un servidor.'),
    ]));
}

class AdminScreen extends StatefulWidget {
  final MedStore store;
  final int initialSubject;
  final int? initialTopic;
  final String? initialCategory;
  const AdminScreen({super.key,required this.store,this.initialSubject=1,this.initialTopic,this.initialCategory});
  @override State<AdminScreen> createState()=>_AdminScreenState();
}
class _AdminScreenState extends State<AdminScreen> {
  final _form=GlobalKey<FormState>();
  final titleCtrl=TextEditingController(),subtitleCtrl=TextEditingController(),
    headingsCtrl=TextEditingController(),urlCtrl=TextEditingController();
  int sid=1,tid=1;
  String category=resourceCategories.first,kind='drive',access='free';
  @override void initState(){super.initState();sid=widget.initialSubject;tid=widget.initialTopic??widget.store.topicsFor(sid).first.id;
    category=widget.initialCategory??resourceCategories.first;
    if(category=='Flashcards')category=resourceCategories.first;
  }
  @override void dispose(){titleCtrl.dispose();subtitleCtrl.dispose();headingsCtrl.dispose();urlCtrl.dispose();super.dispose();}
  Future<void> _save() async {
    if(!(_form.currentState?.validate()??false))return;
    final newItem=StudyResource(id:'own_${DateTime.now().microsecondsSinceEpoch}',
      title:titleCtrl.text.trim(),subtitle:subtitleCtrl.text.trim(),
      headings:headingsCtrl.text.split('\n').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(),
      category:category,kind:kind,url:urlCtrl.text.trim(),access:access,source:'Enlace registrado en el dispositivo',
      note:'Metadatos introducidos manualmente para la búsqueda interna.',subjectId:sid,topicId:tid);
    await widget.store.addResource(newItem);
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Recurso guardado en este dispositivo.')));
    titleCtrl.clear();subtitleCtrl.clear();headingsCtrl.clear();urlCtrl.clear();setState((){});
  }
  @override Widget build(BuildContext context) {
    final topics=widget.store.topicsFor(sid);
    return Scaffold(appBar:AppBar(title:const Text('Administración · demo')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        const Text('Registrar recursos propios o autorizados',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
        const SizedBox(height:8),const Text('Cada archivo de Drive se registra individualmente. Esta pantalla no sube archivos y no controla permisos remotos. Los títulos, subtítulos y capítulos alimentan el buscador interno.'),
        const SizedBox(height:15),Form(key:_form,child:Column(children:[
          DropdownButtonFormField<int>(value:sid,isExpanded:true,decoration:const InputDecoration(labelText:'Asignatura'),
            items:widget.store.subjects.map((s)=>DropdownMenuItem(value:s.id,child:Text(s.name,overflow:TextOverflow.ellipsis))).toList(),
            onChanged:(v)=>setState((){sid=v??1;tid=widget.store.topicsFor(sid).first.id;})),
          const SizedBox(height:12),DropdownButtonFormField<int>(key:ValueKey(sid),value:tid,isExpanded:true,
            decoration:const InputDecoration(labelText:'Tema'),
            items:topics.map((t)=>DropdownMenuItem(value:t.id,child:Text('${t.id}. ${t.title}',overflow:TextOverflow.ellipsis))).toList(),
            onChanged:(v)=>setState(()=>tid=v??tid)),
          const SizedBox(height:12),DropdownButtonFormField<String>(value:category,isExpanded:true,
            decoration:const InputDecoration(labelText:'Categoría'),
            items:resourceCategories.where((c)=>c!='Flashcards').map((c)=>DropdownMenuItem(value:c,child:Text(c,overflow:TextOverflow.ellipsis))).toList(),
            onChanged:(v)=>setState(()=>category=v??category)),
          const SizedBox(height:12),TextFormField(controller:titleCtrl,decoration:const InputDecoration(labelText:'Título del libro / material'),
            validator:(v)=>v==null||v.trim().isEmpty?'Introduce el título':null),
          const SizedBox(height:12),TextFormField(controller:subtitleCtrl,decoration:const InputDecoration(labelText:'Subtítulo (opcional)')),
          const SizedBox(height:12),TextFormField(controller:headingsCtrl,minLines:3,maxLines:6,
            decoration:const InputDecoration(labelText:'Títulos y subtítulos de capítulos (uno por línea)',
              hintText:'Introducción\nShock cardiogénico\nDiagnóstico y tratamiento')),
          const SizedBox(height:12),DropdownButtonFormField<String>(value:kind,
            decoration:const InputDecoration(labelText:'Tipo de enlace'),
            items:const [DropdownMenuItem(value:'drive',child:Text('Archivo Google Drive')),
              DropdownMenuItem(value:'web',child:Text('Página o PDF web')),
              DropdownMenuItem(value:'youtube',child:Text('YouTube gratuito / no listado')),
              DropdownMenuItem(value:'video',child:Text('Video directo alojado externamente'))],
            onChanged:(v)=>setState(()=>kind=v??kind)),
          const SizedBox(height:12),TextFormField(controller:urlCtrl,keyboardType:TextInputType.url,
            decoration:const InputDecoration(labelText:'Enlace HTTPS del archivo o video',hintText:'https://...'),
            validator:(v){final u=Uri.tryParse(v?.trim()??'');
              if(u==null||u.scheme!='https'||u.host.isEmpty)return 'Introduce una URL HTTPS válida';return null;}),
          const SizedBox(height:12),DropdownButtonFormField<String>(value:access,
            decoration:const InputDecoration(labelText:'Visibilidad declarada (solo demo)'),
            items:const [DropdownMenuItem(value:'free',child:Text('Gratuito')),
              DropdownMenuItem(value:'paid',child:Text('Restringido · sin protección real'))],
            onChanged:(v)=>setState(()=>access=v??access)),
          const SizedBox(height:18),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_save,
            icon:const Icon(Icons.add_link),label:const Text('Guardar recurso local'))),
        ])),const SizedBox(height:20),
        Text('Enlaces agregados: ${widget.store.resources.where((r)=>r.id.startsWith('own_')).length}',
          style:Theme.of(context).textTheme.titleMedium),
        for(final item in widget.store.resources.where((r)=>r.id.startsWith('own_')).toList())Card(
          child:ListTile(title:Text(item.title),subtitle:Text('${widget.store.subject(item.subjectId).shortName} • ${item.headings.length} encabezados indexados'),
            trailing:IconButton(tooltip:'Eliminar recurso',icon:const Icon(Icons.delete_outline),
              onPressed:() async {await widget.store.deleteOwnResource(item.id);if(mounted)setState((){});}))),
        const SizedBox(height:10),const Text('Para protección comercial: integrar autenticación, panel de gestión remoto y entrega de archivos mediante permisos verificados en servidor.'),
      ]));
  }
}
