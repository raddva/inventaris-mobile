import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventaris/screens/master_category.dart';
import 'package:inventaris/screens/master_pj.dart';
import 'package:inventaris/screens/master_product.dart';
import 'package:inventaris/screens/master_status.dart';
import 'package:inventaris/screens/master_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAdmin = false;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;

      setState(() {
        isAdmin = userData['isadmin'] ?? false;
        isLoading = false;
      });
    } else {
      setState(() {
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Inventory'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  if (isAdmin)
                    _buildCard("User", Icons.person, Colors.blue, ListUser()),
                  _buildCard("Category", Icons.category, Colors.purple,
                      ListCategory()),
                  _buildCard("PJ & Location", Icons.location_pin, Colors.orange,
                      ListPJ()),
                  _buildCard(
                      "Status", Icons.check_circle, Colors.green, ListStatus()),
                  _buildCard("Product", Icons.shopping_cart, Colors.teal,
                      ListProduct()),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, Widget route) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
