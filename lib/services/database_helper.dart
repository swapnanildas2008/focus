import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_item.dart';
import '../models/focus_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'forest_focus.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        dueTime INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 0,
        colorIndex INTEGER NOT NULL DEFAULT 0,
        estimatedMinutes INTEGER NOT NULL DEFAULT 25
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        durationMinutes INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        todoItemId INTEGER,
        FOREIGN KEY (todoItemId) REFERENCES todo_items (id)
      )
    ''');
  }

  Future<int> insertTodoItem(TodoItem todoItem) async {
    final db = await database;
    return await db.insert('todo_items', todoItem.toMap());
  }

  Future<List<TodoItem>> getTodoItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todo_items',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => TodoItem.fromMap(maps[i]));
  }

  Future<int> updateTodoItem(TodoItem todoItem) async {
    final db = await database;
    return await db.update(
      'todo_items',
      todoItem.toMap(),
      where: 'id = ?',
      whereArgs: [todoItem.id],
    );
  }

  Future<int> deleteTodoItem(int id) async {
    final db = await database;
    return await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertFocusSession(FocusSession session) async {
    final db = await database;
    return await db.insert('focus_sessions', session.toMap());
  }

  Future<List<FocusSession>> getFocusSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'focus_sessions',
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => FocusSession.fromMap(maps[i]));
  }
}
