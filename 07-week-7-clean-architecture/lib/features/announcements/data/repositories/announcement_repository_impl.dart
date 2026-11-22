import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

typedef AnnouncementRowsLoader = Future<List<Map<String, dynamic>>> Function();

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl({required AnnouncementRowsLoader loadRows})
    : _loadRows = loadRows;

  final AnnouncementRowsLoader _loadRows;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements() async {
    try {
      final rows = await _loadRows();
      final announcements = rows
          .map(AnnouncementModel.fromMap)
          .map((model) => model.toEntity())
          .toList();
      return (announcements: announcements, failure: null);
    } catch (_) {
      return (
        announcements: <Announcement>[],
        failure: const LocalFailure(
          'Gagal memuat pengumuman dari penyimpanan lokal.',
        ),
      );
    }
  }
}
