import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/dashboard';

  static Future<List<dynamic>> getPieChartData() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/piechart'),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chart data');
    }
  }

  static Future<List<dynamic>> getCountPlacement() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/penempatan'),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load count');
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
