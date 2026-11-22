import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../data/providers.dart' as legacy;
import '../../../../data/sync.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRowsLoaderProvider = Provider<AnnouncementRowsLoader>((ref) {
  return () => loadPostsCacheFirst(
    dio: ref.watch(legacy.postsDioProvider),
    forceOffline: ref.watch(legacy.forceOfflineProvider),
    onUpdated: () {},
  );
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    loadRows: ref.watch(announcementRowsLoaderProvider),
  );
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  final failure = result.failure;
  if (failure != null) throw failure;
  return result.announcements;
});

String announcementErrorMessage(Object error) {
  if (error case final Failure failure) return failure.message;
  return 'Gagal memuat pengumuman.';
}
