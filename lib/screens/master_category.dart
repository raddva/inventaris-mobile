import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/category_model.dart';

class ListCategory extends StatefulWidget {
  const ListCategory({super.key});

  @override
  State<ListCategory> createState() => _ListCategoryState();
}

class _ListCategoryState extends State<ListCategory> {
  final CategoryController _controller = CategoryController();
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final fetchedData = await _controller.fetchCategories();
      setState(() {
        categories = fetchedData ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Failed to load categories: $e");
    }
  }

  Future<void> _addCategory() async {
    TextEditingController codeController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Category code"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Category Name"),
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
                  await _controller.addCategory(
                    codeController.text,
                    nameController.text,
                  );
                  await _loadCategories();
                } catch (e) {
                  _showError("Failed to add category: $e");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCategory(int categoryId) async {
    try {
      final categoryDetails = await _controller.fetchCategoryDetail(categoryId);

      TextEditingController codeController =
          TextEditingController(text: categoryDetails['kode']);
      TextEditingController nameController =
          TextEditingController(text: categoryDetails['nama']);
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit Category: ${categoryDetails['nama']}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: "Category code"),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Category Name"),
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
                    await _controller.editCategory(categoryDetails['id'] as int,
                        codeController.text, nameController.text);
                    await _loadCategories();
                  } catch (e) {
                    _showError("Failed to edit category: $e");
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError("Failed to fetch category details: $e");
    }
  }

  Future<void> _removeCategory(int id) async {
    try {
      await _controller.removeCategory(id);
      await _loadCategories();
    } catch (e) {
      _showError("Failed to remove category: $e");
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
        title: const Text("Category List"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${category['kode'] ?? '-'} (${category['nama'] ?? '-'})",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editCategory(category['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeCategory(category['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
