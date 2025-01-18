import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/inventory_model.dart';
import 'package:inventaris/modules/api_services.dart';
import 'package:inventaris/screens/trans_inventory_detail.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<Inventory> _inventories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventories();
  }

  Future<void> _fetchInventories() async {
    try {
      final data = await ApiService.fecthInventories();
      setState(() {
        _inventories = data.map((json) => Inventory.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _inventories.length,
              itemBuilder: (context, index) {
                final inventory = _inventories[index];
                return ListTile(
                  title: Text(inventory.transcode),
                  subtitle: Text(inventory.remark),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InventoryDetailListScreen(headerId: inventory.id),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
