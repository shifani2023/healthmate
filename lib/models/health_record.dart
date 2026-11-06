class HealthRecord {
  final int? id;
  final String date; // yyyy-MM-dd
  final int steps;
  final int calories;
  final int waterMl;

  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.waterMl,
  });

  // Convert a database row (Map) into a Dart object.
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      steps: map['steps'] as int,
      calories: map['calories'] as int,
      waterMl: map['water_ml'] as int,
    );
  }

  // Convert a Dart object into a Map that SQLite can store.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water_ml': waterMl,
    };
  }
}