import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  final String apiUrl = "http://127.0.0.1:8000/api/user";

  Future<List<Map<String, dynamic>>?> fetchUsers() async {
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
        throw Exception("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<Map<String, dynamic>> fetchUserDetail(int id) async {
    final token = await getToken();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<void> addUser(String username, String displayName, String password,
      bool isActive, bool isAdmin) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'displayname': displayName,
          'password': password,
          'isactive': isActive,
          'isadmin': isAdmin,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add user: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding user: $e");
    }
  }

  Future<void> editUser(int id, String username, String displayName,
      String password, bool isActive, bool isAdmin) async {
    try {
      final token = await getToken();
      Map<String, dynamic> requestBody = {
        'username': username,
        'displayname': displayName,
        'isactive': isActive,
        'isadmin': isAdmin,
      };

      if (password.isNotEmpty) {
        requestBody['password'] = password;
      }

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to edit user: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error editing user: $e");
    }
  }

  Future<void> removeUser(int id) async {
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
        throw Exception("Failed to delete user: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting user: $e");
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
