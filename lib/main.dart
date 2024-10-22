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
  late Future<List<Task>> taskList; 
  final TextEditingController _titleController = TextEditingController(); 
  final TextEditingController _descriptionController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    taskList = DatabaseHelper().getTasks(); 
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController, 
                decoration: InputDecoration(labelText: 'Title'), 
              ),
              TextField(
                controller: _descriptionController, 
                decoration: InputDecoration(labelText: 'Description'), 
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addTask(); 
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Input'),
          content: Text(message), 
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _addTask() async {
    if (_titleController.text.isEmpty) { 
      _showErrorDialog("Invalid title, please input title"); 
      return;
    }

    if (_descriptionController.text.isNotEmpty) { 
      Task newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
      ); 
      await DatabaseHelper().insertTask(newTask); 

      _titleController.clear(); 
      _descriptionController.clear(); 

      setState(() {
        taskList = DatabaseHelper().getTasks(); 
      });

      Navigator.of(context).pop();
    } else {
      _showErrorDialog("Description cannot be empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Task>>(
        future: taskList, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); 
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found.'));
          } else {
            List<Task> tasks = snapshot.data!; 
            return ListView.builder(
              itemCount: tasks.length, 
              itemBuilder: (context, index) {
                Task task = tasks[index];
                return TaskTile(
                  taskTitle: task.title, 
                  isChecked: task.isCompleted, 
                  checkboxCallback: (bool? checkboxState) {
                    setState(() {
                      task.isCompleted = checkboxState!; 
                      DatabaseHelper().updateTask(task);
                    });
                  },
                  deleteCallback: () {
                    setState(() {
                      DatabaseHelper().deleteTask(task.id!); 
                      taskList = DatabaseHelper().getTasks(); 
                    });
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: _showAddTaskDialog, 
      ),
    );
  }
}

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
  });//required

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
