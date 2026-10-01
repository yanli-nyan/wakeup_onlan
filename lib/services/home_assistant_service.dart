import 'dart:convert';
import 'dart:io';

class HomeAssistantService {
  final String baseUrl;
  final String token;

  HomeAssistantService({required this.baseUrl, required this.token});

  Future<Map<String, dynamic>?> _get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await HttpClient().getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await HttpClient().postUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode(body)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody.isNotEmpty) {
          return jsonDecode(responseBody) as Map<String, dynamic>;
        }
        return {};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getEntityState(String entityId) async {
    final data = await _get('/api/states/$entityId');
    if (data != null && data['state'] != null) {
      return data['state'] as String;
    }
    return null;
  }

  Future<bool> isEntityOn(String entityId) async {
    final state = await getEntityState(entityId);
    return state == 'on';
  }

  Future<bool> turnOnSwitch(String entityId) async {
    final result = await _post('/api/services/switch/turn_on', {
      'entity_id': entityId,
    });
    return result != null;
  }

  Future<bool> turnOffSwitch(String entityId) async {
    final result = await _post('/api/services/switch/turn_off', {
      'entity_id': entityId,
    });
    return result != null;
  }
}
