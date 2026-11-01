import '../routes.dart';

String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String? ?? AppRoutes.home;

  return route.startsWith('/') ? route : '/$route';
}