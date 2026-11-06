import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'healthmate.db');

    print('DATABASE LOCATION: $path'); // check db path
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water_ml INTEGER NOT NULL
      )
    ''');

    // Dummy records for testing: today and the 6 days before it.
    final dummySteps = [7850, 6200, 9100, 5400, 10250, 8300, 4700];
    final dummyCalories = [420, 350, 510, 300, 560, 440, 260];
    final dummyWater = [2000, 1500, 2200, 1200, 2500, 1800, 900];

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      await db.insert('health_records', {
        'date': _formatDate(day),
        'steps': dummySteps[i],
        'calories': dummyCalories[i],
        'water_ml': dummyWater[i],
      });
    }
  }

  Future<int> insertRecord(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('health_records', row);
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await database;
    return db.query(
      'health_records',
      orderBy: 'date DESC, id DESC',
    );
  }

  Future<int> updateRecord(int id, Map<String, dynamic> row) async {
    final db = await database;
    return db.update(
      'health_records',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getRecordsByDate(String date) async {
    final db = await database;
    return db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
  }
}