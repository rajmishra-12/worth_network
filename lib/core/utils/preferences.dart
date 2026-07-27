import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Key names
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyUsername = 'username';
  static const String _keyName = 'name';

  // Getters & Setters
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  set isLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  String get userId => _prefs.getString(_keyUserId) ?? '';
  set userId(String value) => _prefs.setString(_keyUserId, value);

  String get email => _prefs.getString(_keyEmail) ?? '';
  set email(String value) => _prefs.setString(_keyEmail, value);

  String get username => _prefs.getString(_keyUsername) ?? '';
  set username(String value) => _prefs.setString(_keyUsername, value);

  String get name => _prefs.getString(_keyName) ?? '';
  set name(String value) => _prefs.setString(_keyName, value);

  Future<void> clear() async {
    await _prefs.clear();
  }
}
