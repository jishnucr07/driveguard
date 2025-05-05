import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';

  // Save session data
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, userJson);
  }

  // Retrieve session data
  static Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userJson = prefs.getString(_userKey);

    if (accessToken != null && refreshToken != null && userJson != null) {
      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userJson': userJson,
      };
    }
    return null;
  }

  // Clear session data
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
