class AudioRelax {
  final int id;
  final int audioCategoryId;
  final String title;
  final String? description;
  final String audioPath; // Could be YouTube URL or local file path
  final int durationSeconds;
  final String? thumbnailPath;
  final String? artist;
  final int downloadCount;
  final int playCount;
  final double rating;
  final int ratingCount;
  final bool isPremium;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AudioCategory? category;

  AudioRelax({
    required this.id,
    required this.audioCategoryId,
    required this.title,
    this.description,
    required this.audioPath,
    required this.durationSeconds,
    this.thumbnailPath,
    this.artist,
    required this.downloadCount,
    required this.playCount,
    required this.rating,
    required this.ratingCount,
    required this.isPremium,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory AudioRelax.fromJson(Map<String, dynamic> json) {
    return AudioRelax(
      id: json['id'],
      audioCategoryId: json['audio_category_id'],
      title: json['title'],
      description: json['description'],
      audioPath: json['audio_path'],
      durationSeconds: json['duration_seconds'],
      thumbnailPath: json['thumbnail_path'],
      artist: json['artist'],
      downloadCount: json['download_count'] ?? 0,
      playCount: json['play_count'] ?? 0,
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      ratingCount: json['rating_count'] ?? 0,
      isPremium: json['is_premium'] == 1,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      category: json['category'] != null
          ? AudioCategory.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audio_category_id': audioCategoryId,
      'title': title,
      'description': description,
      'audio_path': audioPath,
      'duration_seconds': durationSeconds,
      'thumbnail_path': thumbnailPath,
      'artist': artist,
      'download_count': downloadCount,
      'play_count': playCount,
      'rating': rating,
      'rating_count': ratingCount,
      'is_premium': isPremium ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to check if audio is from YouTube
  bool get isYouTubeAudio {
    return audioPath.contains('youtube.com') || 
           audioPath.contains('youtu.be');
  }

  // Helper method to extract YouTube video ID
  String? get youTubeVideoId {
    if (!isYouTubeAudio) return null;
    
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(audioPath);
    return match?.group(1);
  }

  // Helper method to get YouTube thumbnail
  String? get youTubeThumbnail {
    final videoId = youTubeVideoId;
    if (videoId == null) return thumbnailPath;
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  // Helper method to format duration
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class AudioCategory {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? colorCode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AudioCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.colorCode,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      colorCode: json['color_code'],
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color_code': colorCode,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}