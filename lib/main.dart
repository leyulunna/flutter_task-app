import 'package:flutter/material.dart';
import 'package:flutter_application_1/databaseHelper.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<String> tasks = ['Buy Bread', 'Buy Milk', 'Go to the gym'];
  List<bool> taskCompletion = [false, false, false];

  // fetch taskList from sqflite
  late Future<List<Task>> taskList;

  @override
  void initState() {
    super.initState();
    taskList = DatabaseHelper().getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '${tasks.length} Tasks',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskTile(
                  taskTitle: tasks[index],
                  isChecked: taskCompletion[index],
                  checkboxCallback: (bool? checkboxState) {
                    setState(() {
                      taskCompletion[index] = checkboxState!;
                    });
                  },
                  deleteCallback: () {
                    setState(() {
                      tasks.removeAt(index);
                      taskCompletion.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {
          // Add a task when clicked
        },
      ),
    );
  }
}

// Custom Widget TaskTile
class TaskTile extends StatelessWidget {
  final String taskTitle;
  final bool isChecked;
  final Function(bool?) checkboxCallback;
  final VoidCallback deleteCallback;

  TaskTile({
    required this.taskTitle,
    required this.isChecked,
    required this.checkboxCallback,
    required this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        taskTitle,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: isChecked,
        onChanged: checkboxCallback,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: deleteCallback,
      ),
    );
  }
}