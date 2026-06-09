class Track {
  const Track({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnail,
    required this.encodedTrack,
    required this.source,
    this.streamUrl,
  });

  final String id;
  final String title;
  final String author;
  final int duration;
  final String thumbnail;
  final String encodedTrack;
  final String source;
  final String? streamUrl;

  Track copyWith({
    String? id,
    String? title,
    String? author,
    int? duration,
    String? thumbnail,
    String? encodedTrack,
    String? source,
    String? streamUrl,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      encodedTrack: encodedTrack ?? this.encodedTrack,
      source: source ?? this.source,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown title',
      author: json['author']?.toString() ?? 'Unknown artist',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      encodedTrack: json['encodedTrack']?.toString() ?? '',
      source: json['source']?.toString() ?? 'unknown',
      streamUrl: json['streamUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'duration': duration,
        'thumbnail': thumbnail,
        'encodedTrack': encodedTrack,
        'source': source,
        if (streamUrl != null) 'streamUrl': streamUrl,
      };

  String get durationLabel {
    final totalSeconds = duration ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
