import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/product_model.dart';
import 'package:inventaris/data_modules/category_model.dart';

class ListProduct extends StatefulWidget {
  const ListProduct({super.key});

  @override
  State<ListProduct> createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  final ProductController _productsController = ProductController();
  final CategoryController _categoryController = CategoryController();
  List<Map<String, dynamic>> products = [];
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
      final fetchedProducts = await _productsController.fetchProducts();
      final fetchedCategories = await _categoryController.fetchCategories();
      setState(() {
        products = fetchedProducts ?? [];
        categories = fetchedCategories ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _addProduct() async {
    String? selectedCategoryId;
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Product"),
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
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
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
                  await _productsController.addProduct(
                    nameController.text,
                    int.parse(selectedCategoryId!),
                    descController.text,
                  );
                  await _loadData();
                } catch (e) {
                  _handleError(e);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProduct(int statusId) async {
    try {
      final statusDetails =
          await _productsController.fetchProductDetail(statusId);

      String? selectedCategoryId = statusDetails['categoryid']?.toString();
      TextEditingController nameController =
          TextEditingController(text: statusDetails['nama']);
      TextEditingController descController =
          TextEditingController(text: statusDetails['deskripsi']);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit Product: ${statusDetails['nama']}"),
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
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
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
                    await _productsController.editProduct(
                      statusId,
                      nameController.text,
                      int.parse(selectedCategoryId!),
                      descController.text,
                    );
                    await _loadData();
                  } catch (e) {
                    _handleError(e);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _removeProduct(int id) async {
    try {
      await _productsController.removeProduct(id);
      await _loadData();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _handleError(Object error) {
    if (error.toString().contains('"message":"Validation error"')) {
      try {
        final errorStartIndex = error.toString().indexOf('{');
        final errorJson =
            jsonDecode(error.toString().substring(errorStartIndex));

        final errors = errorJson['errors'] as Map<String, dynamic>? ?? {};
        _showError(context, 'Validation Error', errors: errors);
      } catch (e) {
        _showError(context, 'An unexpected error occurred.');
      }
    } else {
      _showError(context, error.toString());
    }
  }

  void _showError(BuildContext context, String message,
      {Map<String, dynamic>? errors}) {
    String detailedErrors = '';
    if (errors != null) {
      errors.forEach((_, messages) {
        if (messages is List) {
          detailedErrors += '${messages.join("\n")}\n';
        } else {
          detailedErrors += '$messages\n';
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('$message\n\n$detailedErrors'.trim()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final status = products[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${status['category']['nama'] ?? '-'} - ${status['nama'] ?? '-'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProduct(status['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeProduct(status['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
