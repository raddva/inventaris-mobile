import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatusController {
  final String apiUrl = "http://127.0.0.1:8000/api/status";

  Future<List<Map<String, dynamic>>?> fetchStatuses() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch statuses: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching statuses: $e");
    }
  }

  Future<Map<String, dynamic>> fetchStatusDetail(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load status details');
    }
  }

  Future<void> addStatus(String name, int categoryId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nama': name,
          'categoryid': categoryId,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add status: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding status: $e");
    }
  }

  Future<void> editStatus(int id, String name, int categoryId) async {
    try {
      final token = await getToken();
      Map<String, dynamic> requestBody = {
        'nama': name,
        'categoryid': categoryId,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to edit status: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing status: $e");
    }
  }

  Future<void> removeStatus(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 204) {
        throw Exception("Failed to delete status: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting status: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
