import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/announcements/domain/entities/announcement.dart';
import 'package:week5_offline_notes/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:week5_offline_notes/features/announcements/domain/usecases/get_announcements.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  const FakeAnnouncementRepository({this.items = const [], this.failure});

  final List<Announcement> items;
  final Failure? failure;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements() async {
    return (announcements: items, failure: failure);
  }
}

void main() {
  test('GetAnnouncements mengembalikan data dari repository fake', () async {
    final result = await GetAnnouncements(
      const FakeAnnouncementRepository(
        items: [Announcement(id: 1, title: 'Libur', body: 'Kampus tutup')],
      ),
    ).call();

    expect(result.failure, isNull);
    expect(result.announcements.single.title, 'Libur');
  });

  test(
    'GetAnnouncements mempertahankan LocalFailure dari repository',
    () async {
      const failure = LocalFailure('Cache pengumuman tidak tersedia.');
      final result = await GetAnnouncements(
        const FakeAnnouncementRepository(failure: failure),
      ).call();

      expect(result.announcements, isEmpty);
      expect(result.failure, same(failure));
      expect(result.failure!.message, 'Cache pengumuman tidak tersedia.');
    },
  );
}
