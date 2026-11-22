String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Formats a date without Flutter or intl dependencies.
String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

/// Normalizes a route-like value and falls back to the app root.
String normalizeRoute(String? value) {
  final route = value?.trim() ?? '';
  if (route.isEmpty) return '/';
  return route.startsWith('/') ? route : '/$route';
}

/// Parses an integer route parameter with an optional leading slash.
int? parseRouteId(String? value) {
  final route = value?.trim() ?? '';
  if (route.isEmpty) return null;
  final normalized = route.startsWith('/') ? route.substring(1) : route;
  return int.tryParse(normalized);
}
