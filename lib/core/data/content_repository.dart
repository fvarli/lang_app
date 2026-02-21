import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/content_models.dart';

class ContentRepository {
  static const _assetPath = 'assets/content/mvp_content.json';

  Future<ContentBundle> loadContent() async {
    final raw = await rootBundle.loadString(_assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ContentBundle.fromJson(map);
  }
}
