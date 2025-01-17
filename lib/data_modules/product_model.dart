import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  final String apiUrl = "http://127.0.0.1:8000/api/product";

  Future<List<Map<String, dynamic>>?> fetchProducts() async {
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
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<Map<String, dynamic>> fetchProductDetail(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<void> addProduct(String name, int categoryId, String desc) async {
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
          'deskripsi': desc,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding product: $e");
    }
  }

  Future<void> editProduct(
      int id, String name, int categoryId, String desc) async {
    try {
      final token = await getToken();
      Map<String, dynamic> requestBody = {
        'nama': name,
        'categoryid': categoryId,
        'deskripsi': desc,
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
        throw Exception("Failed to edit product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing product: $e");
    }
  }

  Future<void> removeProduct(int id) async {
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
        throw Exception("Failed to delete product: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
