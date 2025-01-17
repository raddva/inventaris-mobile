import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PJController {
  final String apiUrl = "http://127.0.0.1:8000/api/pj";

  Future<List<Map<String, dynamic>>?> fetchPJs() async {
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
        throw Exception("Failed to fetch pj: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching pj: $e");
    }
  }

  Future<Map<String, dynamic>> fetchPJDetail(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pj details');
    }
  }

  Future<void> addPJ(String code, String name, String location) async {
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
          'kode': code,
          'lokasi': location,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add pj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding pj: $e");
    }
  }

  Future<void> editPJ(int id, String code, String name, String location) async {
    try {
      final token = await getToken();
      Map<String, dynamic> requestBody = {
        'nama': name,
        'kode': code,
        'lokasi': location,
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
        throw Exception("Failed to edit pj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing pj: $e");
    }
  }

  Future<void> removePJ(int id) async {
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
        throw Exception("Failed to delete pj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting pj: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
