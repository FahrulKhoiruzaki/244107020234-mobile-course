
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const String _darkModeKey = 'dark_mode';
  static const String _lastOpenedKey = 'last_opened';

  // Membaca preferensi tema.
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // Menyimpan preferensi tema.
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  // Menyimpan waktu terakhir aplikasi dibuka.
  static Future<void> saveLastOpened() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _lastOpenedKey,
      DateTime.now().toIso8601String(),
    );
  }

  // Membaca waktu terakhir aplikasi dibuka.
  static Future<DateTime?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastOpenedKey);

    if (value == null) return null;

    return DateTime.tryParse(value);
  }
}