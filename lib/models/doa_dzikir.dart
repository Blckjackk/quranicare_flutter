import 'dart:convert';

class DoaDzikir {
  final int id;
  final String grup;
  final String nama;
  final String ar;
  final String tr;
  final String idn;
  final String tentang;
  final List<String> tag;
  final int apiId;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoaDzikir({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
    required this.tag,
    required this.apiId,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoaDzikir.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic tagData) {
      if (tagData == null) return [];
      
      // Handle List (array format)
      if (tagData is List) {
        return tagData.map((e) => e.toString()).toList();
      }
      
      // Handle String (single value or serialized format)
      if (tagData is String) {
        if (tagData.trim().isEmpty) return [];
        
        // Handle JSON array string like '["tag1", "tag2"]'
        if (tagData.startsWith('[') && tagData.endsWith(']')) {
          try {
            final List<dynamic> decoded = jsonDecode(tagData);
            return decoded.map((e) => e.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, treat as single tag
            return [tagData.trim()];
          }
        } 
        // Handle comma-separated string like 'tag1,tag2'
        else if (tagData.contains(',')) {
          return tagData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } 
        // Handle single tag
        else {
          return [tagData.trim()];
        }
      }
      
      return [];
    }

    return DoaDzikir(
      id: json['id'] ?? 0,
      grup: json['grup']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      ar: json['ar']?.toString() ?? '',
      tr: json['tr']?.toString() ?? '',
      idn: json['idn']?.toString() ?? '',
      tentang: json['tentang']?.toString() ?? '',
      tag: parseTags(json['tag']),
      apiId: json['api_id'] ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grup': grup,
      'nama': nama,
      'ar': ar,
      'tr': tr,
      'idn': idn,
      'tentang': tentang,
      'tag': tag,
      'api_id': apiId,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get hasTransliteration => tr.isNotEmpty;
  bool get hasSource => tentang.isNotEmpty;
  bool get hasMultipleTags => tag.length > 1;

  // Get formatted source/reference
  String get formattedSource {
    if (tentang.isEmpty) return '';
    
    // Extract the main source/hadith reference if available
    final lines = tentang.split('\n');
    for (String line in lines) {
      if (line.contains('HR.') || line.contains('QS.')) {
        return line.trim();
      }
    }
    
    // Return first line if no specific source found
    return lines.first.trim();
  }

  // Get main content without source
  String get mainContent {
    if (tentang.isEmpty) return '';
    
    final lines = tentang.split('\n');
    final contentLines = <String>[];
    
    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty && 
          !line.startsWith('HR.') && 
          !line.startsWith('QS.') &&
          !line.startsWith('Sumber:')) {
        contentLines.add(line);
      }
    }
    
    return contentLines.join('\n');
  }

  @override
  String toString() {
    return 'DoaDzikir{id: $id, nama: $nama, grup: $grup}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoaDzikir && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DoaDzikirSession {
  final int id;
  final int userId;
  final int doaDzikirId;
  final DoaDzikir? doaDzikir;
  final int completedCount;
  final int? targetCount;
  final int? durationSeconds;
  final String? moodBefore;
  final String? moodAfter;
  final String? notes;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoaDzikirSession({
    required this.id,
    required this.userId,
    required this.doaDzikirId,
    this.doaDzikir,
    required this.completedCount,
    this.targetCount,
    this.durationSeconds,
    this.moodBefore,
    this.moodAfter,
    this.notes,
    required this.completed,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoaDzikirSession.fromJson(Map<String, dynamic> json) {
    return DoaDzikirSession(
      id: json['id'],
      userId: json['user_id'],
      doaDzikirId: json['doa_dzikir_id'],
      doaDzikir: json['doa_dzikir'] != null ? DoaDzikir.fromJson(json['doa_dzikir']) : null,
      completedCount: json['completed_count'] ?? 0,
      targetCount: json['target_count'],
      durationSeconds: json['duration_seconds'],
      moodBefore: json['mood_before'],
      moodAfter: json['mood_after'],
      notes: json['notes'],
      completed: json['completed'] ?? false,
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'doa_dzikir_id': doaDzikirId,
      'doa_dzikir': doaDzikir?.toJson(),
      'completed_count': completedCount,
      'target_count': targetCount,
      'duration_seconds': durationSeconds,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
      'completed': completed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  Duration get sessionDuration {
    if (durationSeconds != null) {
      return Duration(seconds: durationSeconds!);
    }
    
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  String get formattedDuration {
    final duration = sessionDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  double get completionPercentage {
    if (targetCount == null || targetCount! <= 0) return 0.0;
    return (completedCount / targetCount!).clamp(0.0, 1.0);
  }

  bool get hasProgress => completedCount > 0;
  bool get isInProgress => !completed && hasProgress;
  
  @override
  String toString() {
    return 'DoaDzikirSession{id: $id, completed: $completed, count: $completedCount}';
  }
}

// Pagination helper class
class DoaDzikirPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  DoaDzikirPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory DoaDzikirPagination.fromJson(Map<String, dynamic> json) {
    return DoaDzikirPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'has_more_pages': hasMorePages,
    };
  }
}