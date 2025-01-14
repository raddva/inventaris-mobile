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
}

class User {
  String? token;
  String? message;
  User({this.token, this.message = ""});
  factory User.fromJson(Map<String, dynamic> json, Function fromJsonModel) {
    return User(
        message: "Login Success",
        token: (json['token'] != null) ? fromJsonModel(json['token']) : null);
  }
}

class MyResponse<T> {
  String? token;
  String message;
  MyResponse({this.token, this.message = ""});
  factory MyResponse.fromJson(
      Map<String, dynamic> json, Function fromJsonModel) {
    return MyResponse(
      message: json['message'],
      token: json['token'],
    );
  }
}

class LoginController {
  final LoginRepository _repository = LoginRepository();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  Future<Object> login() async {
    http.Response result = await _repository.login(
        usernameController.text, passwordController.text);

    Map<String, dynamic> myBody = jsonDecode(result.body);
    MyResponse<User> myResponse = MyResponse.fromJson(myBody, User.fromJson);

    debugPrint(myResponse.message);
    if (result.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', myResponse.token ?? "");
      return myResponse;
    } else {
      return myResponse;
    }
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
