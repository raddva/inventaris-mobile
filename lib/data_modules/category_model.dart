import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryController {
  final String apiUrl = "http://127.0.0.1:8000/api/category";

  Future<List<Map<String, dynamic>>?> fetchCategories() async {
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
        throw Exception("Failed to fetch category: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching category: $e");
    }
  }

  Future<Map<String, dynamic>> fetchCategoryDetail(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load category details');
    }
  }

  Future<void> addCategory(String code, String name) async {
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
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add category: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<void> editCategory(int id, String code, String name) async {
    try {
      final token = await getToken();
      Map<String, dynamic> requestBody = {
        'nama': name,
        'kode': code,
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
        throw Exception("Failed to edit category: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing category: $e");
    }
  }

  Future<void> removeCategory(int id) async {
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
        throw Exception("Failed to delete category: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
