import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/journal_entry.dart';
import 'package:uuid/uuid.dart';

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]) {
    _loadEntries();
  }

  Box<JournalEntry>? get _box => Hive.isBoxOpen('journalBox') ? Hive.box<JournalEntry>('journalBox') : null;

  void _loadEntries() {
    if (_box != null) {
      final entries = _box!.values.toList();
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      state = entries;
    }
  }

  Future<void> addEntry({
    required String ambienceTitle,
    required String mood,
    required String content,
  }) async {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      ambienceTitle: ambienceTitle,
      mood: mood,
      content: content,
    );
    
    if (_box != null) {
      await _box!.put(entry.id, entry);
    }
    
    state = [entry, ...state];
  }
}
