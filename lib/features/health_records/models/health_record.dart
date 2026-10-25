class HealthRecord {
  final int? id;
  final String date; // format: yyyy-MM-dd
  final int steps;
  final int calories;
  final int water; // ml

  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });
}