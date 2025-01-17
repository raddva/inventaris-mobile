import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/pj_model.dart';

class ListPJ extends StatefulWidget {
  const ListPJ({super.key});

  @override
  State<ListPJ> createState() => _ListPJState();
}

class _ListPJState extends State<ListPJ> {
  final PJController _controller = PJController();
  List<Map<String, dynamic>> pjs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final fetchedData = await _controller.fetchPJs();
      setState(() {
        pjs = fetchedData ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError("$e");
    }
  }

  Future<void> _addPJ() async {
    TextEditingController codeController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController locController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add PJ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "PJ Code"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "PJ Name"),
              ),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: "Location"),
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
                  await _controller.addPJ(
                    codeController.text,
                    nameController.text,
                    locController.text,
                  );
                  await _loadCategories();
                } catch (e) {
                  _showError("$e");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPJ(int pjId) async {
    try {
      final pjDetails = await _controller.fetchPJDetail(pjId);

      TextEditingController codeController =
          TextEditingController(text: pjDetails['kode']);
      TextEditingController nameController =
          TextEditingController(text: pjDetails['nama']);
      TextEditingController locController =
          TextEditingController(text: pjDetails['lokasi']);
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit PJ: ${pjDetails['nama']}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: "PJ Code"),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "PJ Name"),
                ),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(labelText: "Location"),
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
                    await _controller.editPJ(
                      pjDetails['id'] as int,
                      codeController.text,
                      nameController.text,
                      locController.text,
                    );
                    await _loadCategories();
                  } catch (e) {
                    _showError("$e");
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError("$e");
    }
  }

  Future<void> _removePJ(int id) async {
    try {
      await _controller.removePJ(id);
      await _loadCategories();
    } catch (e) {
      _showError("$e");
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
        title: const Text("PJ List"),
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
              itemCount: pjs.length,
              itemBuilder: (context, index) {
                final pj = pjs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${pj['kode'] ?? '-'} - ${pj['nama'] ?? '-'} (${pj['lokasi'] ?? '-'}) ",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPJ(pj['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removePJ(pj['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPJ,
        child: const Icon(Icons.add),
      ),
    );
  }
}
