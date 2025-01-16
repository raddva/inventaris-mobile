import 'package:flutter/material.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  List<Map<String, String>> users = [
    {"id": "1", "displayName": "John Doe"},
    {"id": "2", "displayName": "Jane Smith"},
  ];

  void _addUser(String name) {
    setState(() {
      users.add({"id": DateTime.now().toString(), "displayName": name});
    });
  }

  void _editUser(String id, String newName) {
    setState(() {
      final user = users.firstWhere((user) => user['id'] == id);
      user['displayName'] = newName;
    });
  }

  void _removeUser(String id) {
    setState(() {
      users.removeWhere((user) => user['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User List")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(user['displayName'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editUser(user['id']!, 'Edited Name');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeUser(user['id']!);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addUser("New User");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormUser extends StatefulWidget {
  const FormUser({super.key});

  @override
  State<FormUser> createState() => _FormUserState();
}

class _FormUserState extends State<FormUser> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
