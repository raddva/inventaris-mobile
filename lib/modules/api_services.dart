import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<dynamic>> fecthInventories() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/inv'),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventories');
    }
  }

  Future<Map<String, dynamic>> getInventory(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$baseUrl/inv/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventory details');
    }
  }

  Future<void> addInventory(
      String code, String date, String remark, int categoryId) async {
    try {
      final token = await getToken();
      final userId = await getUserData();

      if (userId == null) {
        throw Exception("User ID is null. Please log in again.");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/inv'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'transcode': code,
          'transdate': date,
          'remark': remark,
          'categoryid': categoryId,
          'createdby': userId
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add inventory: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding inventory: $e");
    }
  }

  Future<void> editInventory(
      int id, String code, String date, String remark, int categoryId) async {
    try {
      final token = await getToken();
      final userId = await getUserData();

      if (userId == null) {
        throw Exception("User ID is null. Please log in again.");
      }

      Map<String, dynamic> requestBody = {
        'transcode': code,
        'transdate': date,
        'remark': remark,
        'categoryid': categoryId,
        'createdby': userId
      };

      final response = await http.put(
        Uri.parse('$baseUrl/inv/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to edit inventory: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing inventory: $e");
    }
  }

  Future<void> removeInventory(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/inv/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 204) {
        throw Exception("Failed to delete inventory: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting inventory: $e");
    }
  }

  // details
  static Future<List<dynamic>> fetchInventoryDetails(int headerId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/invdt/$headerId'),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventory details');
    }
  }

  Future<void> addInventoryDetail(int headerId, int productId, int statusId,
      String remark, int pjid, int qty) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/invdt'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'headerid': headerId,
          'productid': productId,
          'statusid': statusId,
          'remark': remark,
          'qty': qty
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add inventory detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding inventory detail: $e");
    }
  }

  Future<void> editInventoryDetail(int id, int headerId, int productId,
      int statusId, String remark, int pjid, int qty) async {
    try {
      final token = await getToken();

      Map<String, dynamic> requestBody = {
        'headerid': headerId,
        'productid': productId,
        'statusid': statusId,
        'remark': remark,
        'qty': qty
      };

      final response = await http.put(
        Uri.parse('$baseUrl/invdt/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to edit inventory detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing inventory detail: $e");
    }
  }

  Future<void> removeInventoryDetail(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/invdt/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 204) {
        throw Exception("Failed to delete inventory detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting inventory detail: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<int?> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  if (userJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return userMap['id'];
  }
  return null;
}
