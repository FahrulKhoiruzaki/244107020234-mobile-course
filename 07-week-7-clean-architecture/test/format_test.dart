import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/core/format.dart';

void main() {
  test('formatDate uses stable zero-padded local components', () {
    final value = DateTime(2026, 1, 2, 3, 4);

    expect(formatDate(value), '02/01/2026 03:04');
  });

  test('normalizeRoute uses root for missing values', () {
    expect(normalizeRoute(null), '/');
    expect(normalizeRoute(''), '/');
    expect(normalizeRoute('  '), '/');
  });

  test('normalizeRoute adds a leading slash', () {
    expect(normalizeRoute('announcements'), '/announcements');
    expect(normalizeRoute('/announcements'), '/announcements');
  });

  test('parseRouteId accepts slash and slash-less values', () {
    expect(parseRouteId('/42'), 42);
    expect(parseRouteId('42'), 42);
    expect(parseRouteId('/not-an-id'), isNull);
    expect(parseRouteId(null), isNull);
  });
}
