import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class MedStore extends ChangeNotifier {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  List<Subject> subjects = [];
  List<Topic> topics = [];
  List<StudyResource> resources = [];
  List<FlashcardData> flashcards = [];
  bool darkMode = false;
  String membership = 'Sin membresía';
  DateTime? trialEnds;
  bool trialUsed = false;

  Future<void> load() async {
    Future<dynamic> asset(String path) async => jsonDecode(await rootBundle.loadString(path));
    subjects = (await asset('assets/data/subjects.json') as List)
        .map((x) => Subject.fromJson(Map<String,dynamic>.from(x))).toList();
    topics = (await asset('assets/data/topics.json') as List)
        .map((x) => Topic.fromJson(Map<String,dynamic>.from(x))).toList();
    flashcards = (await asset('assets/data/flashcards.json') as List)
        .map((x) => FlashcardData.fromJson(Map<String,dynamic>.from(x))).toList();
    final bundled = (await asset('assets/data/resources.json') as List)
        .map((x) => StudyResource.fromJson(Map<String,dynamic>.from(x))).toList();
    final saved = await _prefs.getString('med_resources_v1');
    resources = saved == null ? bundled : [...bundled,
      ...(jsonDecode(saved) as List).map((x) => StudyResource.fromJson(Map<String,dynamic>.from(x)))];
    darkMode = await _prefs.getBool('med_dark_v1') ?? false;
    membership = await _prefs.getString('med_membership_v1') ?? 'Sin membresía';
    trialUsed = await _prefs.getBool('med_trial_used_v1') ?? false;
    final value = await _prefs.getString('med_trial_end_v1');
    trialEnds = value == null ? null : DateTime.tryParse(value);
    if (membership == 'Prueba gratuita' && trialEnds != null && DateTime.now().isAfter(trialEnds!)) {
      membership='Sin membresía'; await _prefs.setString('med_membership_v1',membership);
    }
    notifyListeners();
  }
  Subject subject(int id) => subjects.firstWhere((x)=>x.id==id);
  Topic topic(int id) => topics.firstWhere((x)=>x.id==id);
  List<Topic> topicsFor(int sid) => topics.where((x)=>x.subjectId==sid).toList();
  List<StudyResource> resourcesFor(int sid, int tid, String category) => resources.where(
    (r)=>r.subjectId==sid && r.topicId==tid && r.category==category).toList();
  Future<void> setDark(bool value) async { darkMode=value;notifyListeners();await _prefs.setBool('med_dark_v1',value); }
  Future<void> setMembership(String value) async {
    membership=value;
    if(value=='Prueba gratuita') {trialUsed=true;trialEnds=DateTime.now().add(const Duration(days:7));
      await _prefs.setBool('med_trial_used_v1',true); await _prefs.setString('med_trial_end_v1',trialEnds!.toIso8601String());}
    notifyListeners();await _prefs.setString('med_membership_v1',value);
  }
  Future<void> addResource(StudyResource resource) async {
    resources.add(resource);notifyListeners();
    final own=resources.where((x)=>!x.id.startsWith('openstax_') && x.id!='medlineplus_anatomia').map((x)=>x.toJson()).toList();
    await _prefs.setString('med_resources_v1',jsonEncode(own));
  }
  Future<void> deleteOwnResource(String id) async {
    if(id.startsWith('openstax_')||id=='medlineplus_anatomia') return;
    resources.removeWhere((x)=>x.id==id);notifyListeners();
    final own=resources.where((x)=>!x.id.startsWith('openstax_')&&x.id!='medlineplus_anatomia').map((x)=>x.toJson()).toList();
    await _prefs.setString('med_resources_v1',jsonEncode(own));
  }
}
