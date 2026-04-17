class Ambience {
  final String id;
  final String title;
  final String tag;
  final int durationMinutes;
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
    required this.durationMinutes,
    required this.description,
    required this.thumbnailUrl,
    required this.heroUrl,
    required this.audioUrl,
    required this.sensoryMix,
    required this.curatorNotes,
  });

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      durationMinutes: json['durationMinutes'] as int,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      heroUrl: json['heroUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      sensoryMix: List<String>.from(json['sensoryMix'] ?? []),
      curatorNotes: json['curatorNotes'] as String,
    );
  }
}
