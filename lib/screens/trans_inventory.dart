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

  void _refreshInventoryList() {
    _fetchInventories();
  }

  Future<void> _removeInventory(int id) async {
    try {
      await ApiService().removeInventory(id);
      await _fetchInventories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this inventory?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _removeInventory(id); // Proceed with deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(inventory.transcode),
                    subtitle: Text(inventory.remark),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InventoryForm(
                                  inventory: inventory,
                                  onFormSubmit: _refreshInventoryList,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmation(inventory.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryForm(
                onFormSubmit: _refreshInventoryList,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
