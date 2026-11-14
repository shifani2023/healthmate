import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/daily_total.dart';
import '../models/health_record.dart';

// The "shared notebook": it holds the records and tells every screen
// to refresh when something changes.
class HealthProvider extends ChangeNotifier {
  final HealthController _controller = HealthController();

  List<HealthRecord> _records = [];
  bool _isLoading = true;

  List<HealthRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // ---------- load, add, update, delete ----------

  Future<void> loadRecords() async {
    try {
      _records = await _controller.getAllRecords();
    } catch (e) {
      // Only written to the Terminal for the developer
      debugPrint('Could not load records: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord record) async {
    await _controller.addRecord(record);
    await loadRecords();
  }

  Future<void> updateRecord(HealthRecord record) async {
    await _controller.updateRecord(record);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _controller.deleteRecord(id);
    await loadRecords();
  }

  // ---------- filtering ----------

  List<HealthRecord> recordsForDate(DateTime day) {
    final key = _fmt(day);
    return _records.where((r) => r.date == key).toList();
  }

  List<HealthRecord> get todayRecords => recordsForDate(DateTime.now());

  // ---------- today's totals (for the dashboard) ----------

  int get todaySteps =>
      todayRecords.fold(0, (sum, r) => sum + r.steps);
  int get todayCalories =>
      todayRecords.fold(0, (sum, r) => sum + r.calories);
  int get todayWater =>
      todayRecords.fold(0, (sum, r) => sum + r.waterMl);

  // ---------- weekly chart and high score ----------

  // Totals for each of the last 7 days (oldest first, today last)
  List<DailyTotal> get weekTotals {
    final today = DateTime.now();
    final List<DailyTotal> week = [];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final dayRecords = recordsForDate(day);
      week.add(DailyTotal(
        date: day,
        steps: dayRecords.fold(0, (sum, r) => sum + r.steps),
        calories: dayRecords.fold(0, (sum, r) => sum + r.calories),
        waterMl: dayRecords.fold(0, (sum, r) => sum + r.waterMl),
      ));
    }
    return week;
  }

  // High score: the most steps walked in a single day, ever
  int get bestDaySteps {
    final Map<String, int> totals = {};
    for (final r in _records) {
      totals[r.date] = (totals[r.date] ?? 0) + r.steps;
    }
    if (totals.isEmpty) return 0;
    return totals.values.reduce((a, b) => a > b ? a : b);
  }
}