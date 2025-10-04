import 'package:flutter/material.dart';
import '../utils/font_styles.dart';
import 'package:quranicare/services/journal_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReflectionListWidget extends StatelessWidget {
  final List<JournalData> reflections;
  final Function(JournalData)? onReflectionTap;
  final Function(JournalData)? onReflectionEdit;
  final Function(JournalData)? onReflectionDelete;
  final Function(JournalData)? onToggleFavorite;
  final bool showAyahReference;

  const ReflectionListWidget({
    Key? key,
    required this.reflections,
    this.onReflectionTap,
    this.onReflectionEdit,
    this.onReflectionDelete,
    this.onToggleFavorite,
    this.showAyahReference = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reflections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada refleksi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai menulis refleksi dari ayat Al-Quran',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reflections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reflection = reflections[index];
        return ReflectionCard(
          reflection: reflection,
          onTap: onReflectionTap != null ? () => onReflectionTap!(reflection) : null,
          onEdit: onReflectionEdit != null ? () => onReflectionEdit!(reflection) : null,
          onDelete: onReflectionDelete != null ? () => onReflectionDelete!(reflection) : null,
          onToggleFavorite: onToggleFavorite != null ? () => onToggleFavorite!(reflection) : null,
          showAyahReference: showAyahReference,
        );
      },
    );
  }
}

class ReflectionCard extends StatelessWidget {
  final JournalData reflection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final bool showAyahReference;

  const ReflectionCard({
    Key? key,
    required this.reflection,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.showAyahReference = false,
  }) : super(key: key);

  String _getExcerpt(String content, {int maxLength = 100}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reflection.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onToggleFavorite != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onToggleFavorite,
                      child: Icon(
                        reflection.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: reflection.isFavorite ? Colors.red : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              
              // Ayah reference (if enabled)
              if (showAyahReference && reflection.ayah != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.teal[200]!),
                  ),
                  child: Text(
                    'QS. ${reflection.ayah!.surah?.nameIndonesian} : ${reflection.ayah!.number}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Content excerpt
              Text(
                _getExcerpt(reflection.content),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Mood and tags
              Row(
                children: [
                  // Mood
                  if (reflection.mood != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            JournalService.getMoodEmoji(reflection.mood!),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reflection.mood!.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Tags
                  if (reflection.tags.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: reflection.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else
                    const Spacer(),
                ],
              ),

              const SizedBox(height: 12),

              // Date and time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeago.format(reflection.createdAt, locale: 'id'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (reflection.tags.length > 3) ...[
                    Text(
                      '+${reflection.tags.length - 3} tag lainnya',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReflectionDetailModal extends StatelessWidget {
  final JournalData reflection;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const ReflectionDetailModal({
    Key? key,
    required this.reflection,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    reflection.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onToggleFavorite != null)
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      reflection.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: reflection.isFavorite ? Colors.red : Colors.grey[400],
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            // Ayah reference
            if (reflection.ayah != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QS. ${reflection.ayah!.surah?.nameIndonesian} : ${reflection.ayah!.number}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ArabicText(
                      reflection.ayah!.textArabic,
                      style: FontStyles.ayahText.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reflection.ayah!.textIndonesian,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reflection.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mood and tags
                    if (reflection.mood != null || reflection.tags.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      if (reflection.mood != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.sentiment_satisfied, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Perasaan: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(JournalService.getMoodEmoji(reflection.mood!)),
                            const SizedBox(width: 4),
                            Text(
                              reflection.mood!.replaceAll('_', ' '),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (reflection.tags.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.label, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Tag: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: reflection.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue[200]!),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),
                    
                    // Date info
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          'Dibuat ${timeago.format(reflection.createdAt, locale: 'id')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onEdit != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit!();
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (onDelete != null) const SizedBox(width: 12),
                  ],
                  if (onDelete != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete!();
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Hapus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}