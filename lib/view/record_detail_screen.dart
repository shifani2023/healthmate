import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../widgets/background_image.dart';
import '../widgets/metric_card.dart';

class RecordDetailScreen extends StatelessWidget {
  final HealthRecord record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(record.date));

    return BackgroundImage(
      asset: 'images/image.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Record Details'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Steps walked',
              value: record.steps.toString(),
              unit: 'steps',
              icon: Icons.directions_walk,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Calories burned',
              value: record.calories.toString(),
              unit: 'kcal',
              icon: Icons.local_fire_department,
              color: Colors.red,
            ),
            MetricCard(
              title: 'Water intake',
              value: record.waterMl.toString(),
              unit: 'ml',
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              'Record ID: ${record.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}