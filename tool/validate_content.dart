import 'dart:convert';
import 'dart:io';

import 'package:lang_app/core/models/content_models.dart';

Future<void> main() async {
  const path = 'assets/content/mvp_content.json';
  try {
    final raw = await File(path).readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('Validation failed: root must be an object');
      exitCode = 1;
      return;
    }

    final bundle = ContentBundle.fromJson(decoded);
    stdout.writeln(
      'OK: schema v${bundle.schemaVersion}, modules=${bundle.modules.length}, lessons=${bundle.lessons.length}',
    );
  } on ContentValidationException catch (e) {
    stderr.writeln('Validation failed: ${e.message}');
    exitCode = 1;
  } catch (e) {
    stderr.writeln('Validation failed: $e');
    exitCode = 1;
  }
}
