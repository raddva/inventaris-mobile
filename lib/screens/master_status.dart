import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/status_model.dart';

class ListStatus extends StatefulWidget {
  const ListStatus({super.key});

  @override
  State<ListStatus> createState() => _ListStatusState();
}

class _ListStatusState extends State<ListStatus> {
  final StatusController _statusController = StatusController();
  List<Map<String, dynamic>> statuses = [];
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
      setState(() {
        statuses = fetchedStatuses ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _addStatus() async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

  Future<void> _editStatus(int statusId) async {
    try {
      final statusDetails = await _statusController.fetchStatusDetail(statusId);
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

  Future<void> _removeStatus(int id) async {
    try {
      await _statusController.removeStatus(id);
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
                      "${status['nama'] ?? '-'}",
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
