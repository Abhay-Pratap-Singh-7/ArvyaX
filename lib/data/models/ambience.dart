class Ambience {
  final String id;
  final String title;
  final String tag;
  final int durationSeconds;
  final String description;
  final String thumbnailUrl;
  final String heroUrl;
  final String audioUrl;
  final List<String> sensoryMix;
  final String curatorNotes;

  const Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationSeconds,
    required this.description,
    required this.thumbnailUrl,
    required this.heroUrl,
    required this.audioUrl,
    required this.sensoryMix,
    required this.curatorNotes,
  });

  String get formattedDuration {
    if (durationSeconds < 60) {
      return "$durationSeconds sec";
    } else if (durationSeconds >= 3600) {
      final hours = durationSeconds ~/ 3600;
      final minutes = (durationSeconds % 3600) ~/ 60;
      return "${hours}h ${minutes}m";
    } else {
      final minutes = durationSeconds ~/ 60;
      return "$minutes min";
    }
  }

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      durationSeconds: json['durationSeconds'] as int? ?? json['durationMinutes'] as int? ?? 0,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      heroUrl: json['heroUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      sensoryMix: List<String>.from(json['sensoryMix'] ?? []),
      curatorNotes: json['curatorNotes'] as String,
    );
  }
}
