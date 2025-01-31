import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/user_model.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  final UserController _controller = UserController();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsers = await _controller.fetchUsers();
      setState(() {
        users = fetchedUsers ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _addUser() async {
    TextEditingController dnController = TextEditingController();
    TextEditingController unameController = TextEditingController();
    TextEditingController pwController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        bool isActive = true;
        bool isAdmin = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add User"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: unameController,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),
                  TextField(
                    controller: dnController,
                    decoration:
                        const InputDecoration(labelText: "Display Name"),
                  ),
                  TextField(
                    controller: pwController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      const Text("Active"),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Admin"),
                      const Spacer(),
                      Switch(
                        value: isAdmin,
                        onChanged: (value) {
                          setState(() {
                            isAdmin = value;
                          });
                        },
                      ),
                    ],
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
                      await _controller.addUser(
                        unameController.text,
                        dnController.text,
                        pwController.text,
                        isActive,
                        isAdmin,
                      );
                      await _loadUsers();
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
      },
    );
  }

  Future<void> _editUser(int userId) async {
    try {
      final userDetails = await _controller.fetchUserDetail(userId);

      TextEditingController unameController =
          TextEditingController(text: userDetails['username']);
      TextEditingController dnController =
          TextEditingController(text: userDetails['displayname']);
      TextEditingController pwController = TextEditingController();
      bool isActive = userDetails['isactive'] ?? true;
      bool isAdmin = userDetails['isadmin'] ?? false;

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Edit User: ${userDetails['displayname']}"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: unameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    TextField(
                      controller: dnController,
                      decoration:
                          const InputDecoration(labelText: "Display Name"),
                    ),
                    TextField(
                      controller: pwController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Leave empty if not changed",
                      ),
                      obscureText: true,
                    ),
                    Row(
                      children: [
                        const Text("Active"),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Admin"),
                        const Spacer(),
                        Switch(
                          value: isAdmin,
                          onChanged: (value) {
                            setState(() {
                              isAdmin = value;
                            });
                          },
                        ),
                      ],
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
                        String finalPassword = pwController.text.isNotEmpty
                            ? pwController.text
                            : "";
                        await _controller.editUser(
                          userDetails['id'] as int,
                          unameController.text,
                          dnController.text,
                          finalPassword,
                          isActive,
                          isAdmin,
                        );
                        await _loadUsers();
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
        },
      );
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _removeUser(int id) async {
    try {
      await _controller.removeUser(id);
      await _loadUsers();
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
        title: const Text("User List"),
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
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(user['displayname'] ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active: ${user['isactive']}"),
                        Text("Admin: ${user['isadmin']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editUser(user['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeUser(user['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
