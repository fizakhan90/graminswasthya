import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('healthcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        gender TEXT,
        symptoms TEXT
      );
    ''');
  }

  Future<int> registerUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> addPatient(String name, int age, String gender, String symptoms) async {
    final db = await database;
    return await db.insert('patients', {
      'name': name,
      'age': age,
      'gender': gender,
      'symptoms': symptoms,
    });
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await database;
    return await db.query('patients');
  }
}