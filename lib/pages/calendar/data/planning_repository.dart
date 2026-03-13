import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reeducation_entry.dart';

class PlanningRepository {
  static const _storageKey = 'planning_entries';

  static final List<ReeducationEntry> entries = [];

  static Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    entries
      ..clear()
      ..addAll(
        rawList.map(
          (item) => ReeducationEntry.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        ),
      );
  }

  static Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  static Future<void> addEntry(ReeducationEntry entry) async {
    entries.add(entry);
    await saveEntries();
  }

  static Future<void> removeEntry(ReeducationEntry entry) async {
    entries.remove(entry);
    await saveEntries();
  }
}