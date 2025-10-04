class DzikirDoa {
  final int id;
  final int dzikirCategoryId;
  final String title;
  final String arabicText;
  final String? latinText;
  final String indonesianTranslation;
  final String? benefits;
  final String? context;
  final String? source;
  final String? audioPath;
  final int? repeatCount;
  final List<String>? emotionalTags;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DzikirDoa({
    required this.id,
    required this.dzikirCategoryId,
    required this.title,
    required this.arabicText,
    this.latinText,
    required this.indonesianTranslation,
    this.benefits,
    this.context,
    this.source,
    this.audioPath,
    this.repeatCount,
    this.emotionalTags,
    required this.isFeatured,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory DzikirDoa.fromJson(Map<String, dynamic> json) {
    return DzikirDoa(
      id: json['id'],
      dzikirCategoryId: json['dzikir_category_id'],
      title: json['title'],
      arabicText: json['arabic_text'],
      latinText: json['latin_text'],
      indonesianTranslation: json['indonesian_translation'],
      benefits: json['benefits'],
      context: json['context'],
      source: json['source'],
      audioPath: json['audio_path'],
      repeatCount: json['repeat_count'],
      emotionalTags: json['emotional_tags'] != null
          ? List<String>.from(
              json['emotional_tags'] is String
                  ? json['emotional_tags'].split(',')
                  : json['emotional_tags']
            )
          : null,
      isFeatured: json['is_featured'] == 1,
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
      'dzikir_category_id': dzikirCategoryId,
      'title': title,
      'arabic_text': arabicText,
      'latin_text': latinText,
      'indonesian_translation': indonesianTranslation,
      'benefits': benefits,
      'context': context,
      'source': source,
      'audio_path': audioPath,
      'repeat_count': repeatCount,
      'emotional_tags': emotionalTags?.join(','),
      'is_featured': isFeatured ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DzikirCategory {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DzikirCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory DzikirCategory.fromJson(Map<String, dynamic> json) {
    return DzikirCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
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
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}