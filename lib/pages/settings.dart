import 'package:flutter/material.dart';
import 'package:inventaris/screens/master_category.dart';
import 'package:inventaris/screens/master_pj.dart';
import 'package:inventaris/screens/master_product.dart';
import 'package:inventaris/screens/master_status.dart';
import 'package:inventaris/screens/master_user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard("Master User", Icons.person, Colors.blue, ListUser()),
            _buildCard("Master Status", Icons.check_circle, Colors.green,
                ListStatus()),
            _buildCard(
                "Master PJ", Icons.location_pin, Colors.orange, ListPJ()),
            _buildCard("Master Category", Icons.category, Colors.purple,
                ListCategory()),
            _buildCard("Master Product", Icons.shopping_cart, Colors.teal,
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
          Navigator.pushReplacement(
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
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
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
