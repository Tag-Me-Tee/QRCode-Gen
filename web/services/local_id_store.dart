import 'dart:html' as html;

import '../core/constants/app_config.dart';

class LocalIdStore {
  Future<List<String>> loadExistingIds() async {
    try {
      final response = await html.HttpRequest.getString(AppConfig.idsFilePath);
      return response
          .split('\n')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
