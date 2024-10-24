import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'tasks.db');
      print("Database path: $path");
      return await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) {
          print("Creating tasks table");
          return db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              isCompleted INTEGER
            )
          ''');
        },
        onUpgrade: onUpgrade,
      );
    } catch (e) {
      print("Error initializing database: $e");
      throw Exception("Database initialization failed");
    }
  }


  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isCompleted INTEGER
      )

        ALTER TABLE tasks ADD COLUMN description TEXT;
      ''');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }


  Future<void> insertTask(Task task) async {
    try {
      final db = await database;
      await db.insert('tasks', task.toMap());
      print("Inserted task: ${task.title}");
    } catch (e) {
      print("Error inserting task: $e");
    }
  }


  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

class Task {
  int? id;
  String title;
  String description;
  bool isCompleted;

  Task({this.id, required this.title, required this.description, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
