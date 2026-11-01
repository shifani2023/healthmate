import 'package:flutter/foundation.dart';
import '../models/health_record.dart';

class HealthRecordProvider extends ChangeNotifier {
  final List<HealthRecord> _records = [];
  int _nextId = 1;
  String _searchDate = '';

  HealthRecordProvider() {
    _loadDummyData();
  }

  static String formatDate(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  void _loadDummyData() {
    final now = DateTime.now();
    const steps = [7850, 6200, 9100, 4300, 10250];
    const calories = [420, 350, 510, 240, 600];
    const water = [2000, 1500, 2500, 1200, 2800];
    for (int i = 0; i < 5; i++) {
      _records.add(HealthRecord(
        id: _nextId++,
        date: formatDate(now.subtract(Duration(days: i))),
        steps: steps[i],
        calories: calories[i],
        water: water[i],
      ));
    }
  }

  String get searchDate => _searchDate;

  // Records filtered by the search date, newest first
  List<HealthRecord> get records {
    final list = _searchDate.isEmpty
        ? List<HealthRecord>.from(_records)
        : _records.where((r) => r.date == _searchDate).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Iterable<HealthRecord> get _todayRecords {
    final today = formatDate(DateTime.now());
    return _records.where((r) => r.date == today);
  }

  int get todaySteps => _todayRecords.fold(0, (sum, r) => sum + r.steps);
  int get todayCalories => _todayRecords.fold(0, (sum, r) => sum + r.calories);
  int get todayWater => _todayRecords.fold(0, (sum, r) => sum + r.water);

  void setSearchDate(String date) {
    _searchDate = date;
    notifyListeners();
  }

  void addRecord(HealthRecord record) {
    _records.add(HealthRecord(
      id: _nextId++,
      date: record.date,
      steps: record.steps,
      calories: record.calories,
      water: record.water,
    ));
    notifyListeners();
  }

  void deleteRecord(int id) {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
