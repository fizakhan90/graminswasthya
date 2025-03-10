import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "healthcare.db";
  static final _databaseVersion = 1;

  // Users table
  static final userTable = 'users';
  static final columnId = 'id';
  static final columnHealthcareId = 'healthcare_id';
  static final columnName = 'name';
  static final columnPassword = 'password';

  // Patients table
  static final patientTable = 'patients';
  static final columnPatientId = 'id';
  static final columnPatientName = 'name';
  static final columnPatientAge = 'age';
  static final columnPatientGender = 'gender';
  static final columnPatientSymptoms = 'symptoms';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Create tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnHealthcareId TEXT NOT NULL UNIQUE,
        $columnName TEXT NOT NULL,
        $columnPassword TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $patientTable (
        $columnPatientId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPatientName TEXT NOT NULL,
        $columnPatientAge INTEGER NOT NULL,
        $columnPatientGender TEXT NOT NULL,
        $columnPatientSymptoms TEXT NOT NULL
      )
    ''');
  }

  // Register a new user
  Future<int> registerUser(String healthcareId, String password, String name) async {
    Database db = await database;
    
    // Check if healthcare ID already exists
    final existingUser = await db.query(
      userTable,
      where: '$columnHealthcareId = ?',
      whereArgs: [healthcareId],
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('Healthcare ID already exists');
    }
    
    Map<String, dynamic> row = {
      columnHealthcareId: healthcareId,
      columnName: name,
      columnPassword: password
    };
    
    return await db.insert(userTable, row);
  }

  // Login user
  Future<Map<String, dynamic>?> loginUser(String healthcareId, String password) async {
    Database db = await database;
    
    List<Map<String, dynamic>> result = await db.query(
      userTable,
      where: '$columnHealthcareId = ? AND $columnPassword = ?',
      whereArgs: [healthcareId, password],
    );
    
    if (result.isEmpty) {
      return null;
    }
    
    return result.first;
  }

  // Add a new patient
  Future<int> addPatient(String name, int age, String gender, String symptoms) async {
    Database db = await database;
    
    Map<String, dynamic> row = {
      columnPatientName: name,
      columnPatientAge: age,
      columnPatientGender: gender,
      columnPatientSymptoms: symptoms
    };
    
    return await db.insert(patientTable, row);
  }

  // Get all patients
  Future<List<Map<String, dynamic>>> getPatients() async {
    Database db = await database;
    return await db.query(patientTable, orderBy: '$columnPatientId DESC');
  }
}