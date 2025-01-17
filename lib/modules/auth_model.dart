import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LoginRepository {
  Future<http.Response> login(String username, String password) {
    return http.post(
      Uri.parse("http://127.0.0.1:8000/api/auth/signin"),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8"
      },
      body: jsonEncode(
        <String, String>{
          'username': username,
          'password': password,
        },
      ),
    );
  }

  Future<http.Response> fetchUserDetails(String token) {
    return http.get(
      Uri.parse("http://127.0.0.1:8000/api/auth/session"),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
  }
}

class User {
  int? id;
  String? username;
  String? displayName;
  bool? isActive;
  bool? isAdmin;

  User({
    this.id,
    this.username,
    this.displayName,
    this.isActive,
    this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      displayName: json['displayname'],
      isActive: json['isactive'],
      isAdmin: json['isadmin'],
    );
  }
}

class MyResponse<T> {
  String? token;
  String message;
  T? data;

  MyResponse({this.token, this.message = "", this.data});

  factory MyResponse.fromJson(Map<String, dynamic> json) {
    return MyResponse(
      token: json['token'],
      message: json.containsKey('message')
          ? json['message']
          : "Operation successful",
    );
  }
}

class LoginController {
  final LoginRepository _repository = LoginRepository();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  Future<MyResponse<User>> login() async {
    try {
      http.Response result = await _repository.login(
        usernameController.text,
        passwordController.text,
      );

      if (result.statusCode == 200) {
        Map<String, dynamic> myBody = jsonDecode(result.body);
        MyResponse<User> myResponse = MyResponse.fromJson(myBody);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', myResponse.token ?? "");

        // Fetch user details
        var userResponse = await fetchUserDetails(myResponse.token ?? "");
        if (userResponse != null) {
          myResponse.data = userResponse;
        }

        return myResponse;
      } else {
        return MyResponse<User>(
          message: "Login failed. Please check your credentials.",
        );
      }
    } catch (e) {
      return MyResponse<User>(
        message: "An error occurred: ${e.toString()}",
      );
    }
  }

  Future<User?> fetchUserDetails(String token) async {
    try {
      http.Response result = await _repository.fetchUserDetails(token);

      if (result.statusCode == 200) {
        Map<String, dynamic> userDetails = jsonDecode(result.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('user', jsonEncode(userDetails));

        return User.fromJson(userDetails);
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
    return null;
  }

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/auth/signout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Logout successful');
        return;
      } else {
        print('Logout failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during logout: $e');
      return null;
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<User?> getUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  if (userJson != null) {
    return User.fromJson(jsonDecode(userJson));
  }
  return null;
}
