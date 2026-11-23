import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/todo_model.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future loadTodos() async {
    final data = await DatabaseHelper.instance.getTodos();

    setState(() {
      todos = data;
    });
  }

  Future addTodo() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await DatabaseHelper.instance.insertTodo(
                  Todo(
                    title: titleController.text,
                    description: descController.text,
                  ),
                );

                Navigator.pop(context);
                loadTodos();
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  Future editTodo(Todo todo) async {
    final titleController =
        TextEditingController(text: todo.title);

    final descController =
        TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              todo.title = titleController.text;
              todo.description = descController.text;

              await DatabaseHelper.instance.updateTodo(todo);

              Navigator.pop(context);
              loadTodos();
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  Future toggleTodo(Todo todo) async {
    todo.isDone = !todo.isDone;

    await DatabaseHelper.instance.updateTodo(todo);

    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    int total = todos.length;
    int completed =
        todos.where((e) => e.isDone).length;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 244),

      appBar: AppBar(
        title: const Text("Todo App"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 58, 183, 156),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _infoCard(
                  "Total",
                  total.toString(),
                ),
                _infoCard(
                  "Done",
                  completed.toString(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) =>
                          toggleTodo(todo),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle:
                        Text(todo.description),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text("Edit"),
                          onTap: () =>
                              editTodo(todo),
                        ),
                        PopupMenuItem(
                          child: const Text("Delete"),
                          onTap: () async {
                            await DatabaseHelper
                                .instance
                                .deleteTodo(
                                    todo.id!);

                            loadTodos();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(
      String title,
      String value,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}