import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/inventory_detail_model.dart';
import 'package:inventaris/modules/api_services.dart';

class InventoryDetailListScreen extends StatefulWidget {
  final int headerId;

  const InventoryDetailListScreen({super.key, required this.headerId});

  @override
  State<InventoryDetailListScreen> createState() =>
      _InventoryDetailListScreenState();
}

class _InventoryDetailListScreenState extends State<InventoryDetailListScreen> {
  List<InventoryDetail> _details = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await ApiService.fetchInventoryDetails(widget.headerId);
      setState(() {
        _details = data.map((json) => InventoryDetail.fromJson(json)).toList();
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
      appBar: AppBar(title: const Text('Inventory Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _details.length,
              itemBuilder: (context, index) {
                final detail = _details[index];
                return ListTile(
                  title: Text(detail.product),
                  subtitle: Text('Qty: ${detail.qty}'),
                  trailing: Text(detail.remark),
                );
              },
            ),
    );
  }
}
