import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime? publishedAt;

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['published_at'] ?? map['publishedAt'];
    return AnnouncementModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      publishedAt: rawDate is String ? DateTime.tryParse(rawDate) : null,
    );
  }

  Announcement toEntity() {
    return Announcement(
      id: id,
      title: title,
      body: body,
      publishedAt: publishedAt,
    );
  }
}
