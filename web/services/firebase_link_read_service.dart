import 'dart:convert';
import 'dart:html' as html;

import '../core/constants/app_config.dart';

class FirebaseLinkReadService {
  Future<bool> idExists(String id) async {
    final endpoint =
        '${AppConfig.firebaseDatabaseBaseUrl}/${AppConfig.firebaseLinksPath}/$id.json';

    final response = await html.HttpRequest.request(
      endpoint,
      method: 'GET',
      requestHeaders: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: AppConfig.firebaseReadTimeoutSeconds));

    final statusCode = response.status ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw StateError(
        'Firebase existence check failed for "$id" with status $statusCode.',
      );
    }

    final payload = response.responseText;
    if (payload == null || payload.isEmpty) {
      return false;
    }

    return jsonDecode(payload) != null;
  }
}
