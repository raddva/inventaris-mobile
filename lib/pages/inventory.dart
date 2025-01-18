import 'package:flutter/material.dart';
import 'package:inventaris/screens/trans_inventory.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Transaction'),
        centerTitle: true,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        backgroundColor: Colors.transparent,
      ),
      body: InventoryListScreen(),
    );
  }
}
