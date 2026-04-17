import 'package:hive_flutter/hive_flutter.dart';

class JournalEntry {
  final String id;
  final DateTime dateTime;
  final String ambienceTitle;
  final String mood;
  final String content;

  JournalEntry({
    required this.id,
    required this.dateTime,
    required this.ambienceTitle,
    required this.mood,
    required this.content,
  });
}

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 0;

  @override
  JournalEntry read(BinaryReader reader) {
    return JournalEntry(
      id: reader.readString(),
      dateTime: DateTime.parse(reader.readString()),
      ambienceTitle: reader.readString(),
      mood: reader.readString(),
      content: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.dateTime.toIso8601String());
    writer.writeString(obj.ambienceTitle);
    writer.writeString(obj.mood);
    writer.writeString(obj.content);
  }
}
