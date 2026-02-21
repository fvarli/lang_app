import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/content_models.dart';

class ProgressStore {
  static const _key = 'user_progress_v1';

  Future<UserProgress> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return UserProgress.empty();
    }
    return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> write(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
