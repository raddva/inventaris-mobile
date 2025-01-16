import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LoginRepository {
  Future<http.Response> fetchUSers(String token) {
    return http.get(
      Uri.parse("http://192.168.69.17:8000/api/user"),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': "application/json; charset=UTF-8",
      },
    );
  }
}

class LoginController {
  final LoginRepository _repository = LoginRepository();
}
