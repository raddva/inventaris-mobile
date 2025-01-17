import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/status_model.dart';
import 'package:inventaris/data_modules/category_model.dart';

class ListStatus extends StatefulWidget {
  const ListStatus({super.key});

  @override
  State<ListStatus> createState() => _ListStatusState();
}

class _ListStatusState extends State<ListStatus> {
  final StatusController _statusController = StatusController();
  final CategoryController _categoryController = CategoryController();
  List<Map<String, dynamic>> statuses = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final fetchedStatuses = await _statusController.fetchStatuses();
      final fetchedCategories = await _categoryController.fetchCategories();
      setState(() {
        statuses = fetchedStatuses ?? [];
        categories = fetchedCategories ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Failed to load data: $e");
    }
  }

  Future<void> _addStatus() async {
    String? selectedCategoryId;
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                onChanged: (value) =>
                    setState(() => selectedCategoryId = value),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text("${category['nama'] ?? 'Unknown'}"),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _statusController.addStatus(
                    nameController.text,
                    int.parse(selectedCategoryId!),
                  );
                  await _loadData();
                } catch (e) {
                  _showError("Failed to add status: $e");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editStatus(int statusId) async {
    try {
      final statusDetails = await _statusController.fetchStatusDetail(statusId);

      String? selectedCategoryId = statusDetails['categoryid']?.toString();
      TextEditingController nameController =
          TextEditingController(text: statusDetails['nama']);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit Status: ${statusDetails['nama']}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  onChanged: (value) =>
                      setState(() => selectedCategoryId = value),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text("${category['nama'] ?? 'Unknown'}"),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _statusController.editStatus(
                      statusId,
                      nameController.text,
                      int.parse(selectedCategoryId!),
                    );
                    await _loadData();
                  } catch (e) {
                    _showError("Failed to edit status: $e");
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError("Failed to fetch status details: $e");
    }
  }

  Future<void> _removeStatus(int id) async {
    try {
      await _statusController.removeStatus(id);
      await _loadData();
    } catch (e) {
      _showError("Failed to remove status: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status List"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${status['nama'] ?? '-'}  - ${status['category']['nama'] ?? '-'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editStatus(status['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeStatus(status['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStatus,
        child: const Icon(Icons.add),
      ),
    );
  }
}
