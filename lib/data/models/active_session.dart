import 'package:hive_flutter/hive_flutter.dart';

class ActiveSession {
  final String ambienceId;
  final String ambienceTitle;
  final String audioUrl;
  final int startTimeMs;
  final int durationSeconds;
  final int elapsedSeconds;
  final bool isPlaying;

  ActiveSession({
    required this.ambienceId,
    required this.ambienceTitle,
    required this.audioUrl,
    required this.startTimeMs,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.isPlaying,
  });
}

class ActiveSessionAdapter extends TypeAdapter<ActiveSession> {
  @override
  final int typeId = 1;

  @override
  ActiveSession read(BinaryReader reader) {
    return ActiveSession(
      ambienceId: reader.readString(),
      ambienceTitle: reader.readString(),
      audioUrl: reader.readString(),
      startTimeMs: reader.readInt(),
      durationSeconds: reader.readInt(),
      elapsedSeconds: reader.readInt(),
      isPlaying: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ActiveSession obj) {
    writer.writeString(obj.ambienceId);
    writer.writeString(obj.ambienceTitle);
    writer.writeString(obj.audioUrl);
    writer.writeInt(obj.startTimeMs);
    writer.writeInt(obj.durationSeconds);
    writer.writeInt(obj.elapsedSeconds);
    writer.writeBool(obj.isPlaying);
  }
}
