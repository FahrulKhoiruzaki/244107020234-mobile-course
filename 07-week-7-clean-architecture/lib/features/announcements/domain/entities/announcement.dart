class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime? publishedAt;
}
