import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mr_plannter.db');

    return await openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    // Tasks
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, description TEXT, type TEXT, is_completed INTEGER, 
        frequency TEXT, duration INTEGER, importance INTEGER, 
        scheduled_date TEXT, scheduled_time TEXT, google_event_id TEXT
      )
    ''');
    
    //  Current Plant State
    await db.execute('''
      CREATE TABLE plant_state (
        id INTEGER PRIMARY KEY,
        current_stage INTEGER, 
        total_study_time INTEGER 
      )
    ''');
    await db.insert('plant_state', {'id': 1, 'current_stage': 0, 'total_study_time': 0});

    // Completed Plants (Album)
    await db.execute('''
      CREATE TABLE completed_plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_image_path TEXT,
        plant_name TEXT,
        completion_date TEXT
      )
    ''');
  }

  // Handle updates if app is already installed
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE completed_plants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plant_image_path TEXT,
          plant_name TEXT,
          completion_date TEXT
        )
      ''');
    }
  }


  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('tasks', row);
  }

  Future<List<Map<String, dynamic>>> queryAllTasks() async {
    final db = await database;
    return db.query('tasks', orderBy: 'scheduled_date ASC');
  }

  Future<int> updatePlantState(int newStage, int totalStudyMinutes) async {
    final db = await database;
    final currentState = await getPlantState();
    int currentTotalTime = currentState?['total_study_time'] ?? 0;

    return db.update(
      'plant_state',
      {'current_stage': newStage, 'total_study_time': currentTotalTime + totalStudyMinutes},
      where: 'id = ?', whereArgs: [1],
    );
  }

  Future<Map<String, dynamic>?> getPlantState() async {
    final db = await database;
    final result = await db.query('plant_state', where: 'id = ?', whereArgs: [1]);
    return result.isNotEmpty ? result.first : null;
  }


  // Προσθήκη ολοκληρωμένου φυτού στο άλμπουμ
  Future<int> addCompletedPlant(String imagePath, String name) async {
    final db = await database;
    return await db.insert('completed_plants', {
      'plant_image_path': imagePath,
      'plant_name': name,
      'completion_date': DateTime.now().toIso8601String(),
    });
  }

  // Λήψη όλων των φυτών για το άλμπουμ
  Future<List<Map<String, dynamic>>> getCompletedPlants() async {
    final db = await database;
    return await db.query('completed_plants', orderBy: 'completion_date DESC');
  }
}