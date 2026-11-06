import '../database/database_helper.dart';
import '../models/daily_total.dart';
import '../models/health_record.dart';

class HealthController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String _fmt(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<int> addRecord(HealthRecord record) async {
    return _db.insertRecord(record.toMap());
  }

  Future<List<HealthRecord>> getAllRecords() async {
    final rows = await _db.getAllRecords();
    return rows.map((row) => HealthRecord.fromMap(row)).toList();
  }

  Future<int> updateRecord(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('A record ID is required for updating.');
    }
    return _db.updateRecord(record.id!, record.toMap());
  }

  Future<int> deleteRecord(int id) async {
    return _db.deleteRecord(id);
  }

  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final rows = await _db.getRecordsByDate(date);
    return rows.map((row) => HealthRecord.fromMap(row)).toList();
  }

  Future<List<HealthRecord>> getTodayRecords() async {
    return getRecordsByDate(_fmt(DateTime.now()));
  }

  // Totals for each of the last 7 days (oldest first, today last).
  Future<List<DailyTotal>> getWeekTotals() async {
    final all = await getAllRecords();
    final today = DateTime.now();
    final List<DailyTotal> week = [];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final key = _fmt(day);
      final dayRecords = all.where((r) => r.date == key);
      week.add(DailyTotal(
        date: day,
        steps: dayRecords.fold(0, (sum, r) => sum + r.steps),
        calories: dayRecords.fold(0, (sum, r) => sum + r.calories),
        waterMl: dayRecords.fold(0, (sum, r) => sum + r.waterMl),
      ));
    }
    return week;
  }

  // High score: the most steps walked in a single day, ever.
  Future<int> getBestDaySteps() async {
    final all = await getAllRecords();
    final Map<String, int> totals = {};
    for (final r in all) {
      totals[r.date] = (totals[r.date] ?? 0) + r.steps;
    }
    if (totals.isEmpty) return 0;
    return totals.values.reduce((a, b) => a > b ? a : b);
  }
}