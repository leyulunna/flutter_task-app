import 'package:flutter/material.dart';
import 'package:flutter_application_1/databaseHelper.dart'; // 引入数据库助手类

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
  // 从数据库中获取任务列表
  late Future<List<Task>> taskList; // 定义了 Future 类型的 taskList，从数据库获取任务数据
  final TextEditingController _titleController = TextEditingController(); // [新代码] 定义用于控制 Title 输入框的控制器
  final TextEditingController _descriptionController = TextEditingController(); // [新代码] 定义用于控制 Description 输入框的控制器

  @override
  void initState() {
    super.initState();
    // 初始化时从数据库中获取任务
    taskList = DatabaseHelper().getTasks(); // [已修改] 调用 DatabaseHelper 来获取任务
  }

  // 添加任务的表单弹窗
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
                controller: _titleController, // [新代码] 绑定 title 输入框到 _titleController
                decoration: InputDecoration(labelText: 'Title'), // 输入框提示
              ),
              TextField(
                controller: _descriptionController, // [新代码] 绑定 description 输入框到 _descriptionController
                decoration: InputDecoration(labelText: 'Description'), // 输入框提示
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 取消并关闭弹窗
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // 保存任务到数据库并更新列表
                _addTask(); // [新代码] 保存任务并更新界面
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 添加任务到数据库
  void _addTask() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) { // [新代码] 确保 title 不为空
      Task newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
      ); // 创建 Task 实例
      await DatabaseHelper().insertTask(newTask); // [新代码] 将任务插入数据库

      // 清空输入框
      _titleController.clear(); // [新代码] 清空 title 输入框
      _descriptionController.clear(); // [新代码] 清空 description 输入框

      // 重新加载任务
      setState(() {
        taskList = DatabaseHelper().getTasks(); // [新代码] 更新任务列表
      });
      // 关闭弹窗
      Navigator.of(context).pop(); // 关闭对话框
    }else {
    // 可以显示一个提示，要求用户填写完整信息
    print("Title or description cannot be empty");
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
        future: taskList, // [已修改] 使用 FutureBuilder 来异步加载任务数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载时显示圆形进度条
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 如果出错则显示错误信息
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found.')); // 如果没有任务则显示提示
          } else {
            List<Task> tasks = snapshot.data!; // 获取任务数据
            return ListView.builder(
              itemCount: tasks.length, // [已修改] 展示任务列表
              itemBuilder: (context, index) {
                Task task = tasks[index];
                return TaskTile(
                  taskTitle: task.title, // [已修改] 显示任务的标题
                  isChecked: task.isCompleted, // [已修改] 是否已完成
                  checkboxCallback: (bool? checkboxState) {
                    setState(() {
                      task.isCompleted = checkboxState!; // 更新任务完成状态
                      DatabaseHelper().updateTask(task); // [已修改] 同步到数据库
                    });
                  },
                  deleteCallback: () {
                    setState(() {
                      DatabaseHelper().deleteTask(task.id!); // [已修改] 从数据库删除任务
                      taskList = DatabaseHelper().getTasks(); // [已修改] 重新加载任务列表
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
        onPressed: _showAddTaskDialog, // [已修改] 点击按钮打开添加任务的表单
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
        taskTitle, // 显示任务标题
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null, // 已完成任务划线
        ),
      ),
      leading: Checkbox(
        value: isChecked, // 任务完成状态
        onChanged: checkboxCallback, // 状态改变时回调
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: deleteCallback, // 点击删除按钮删除任务
      ),
    );
  }
}
