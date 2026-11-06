import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_total.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyTotal> days;

  const WeeklyChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    int maxSteps = 0;
    for (final d in days) {
      if (d.steps > maxSteps) maxSteps = d.steps;
    }
    const double chartHeight = 110;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This week's progress (steps)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((d) {
                  final isBest = maxSteps > 0 && d.steps == maxSteps;
                  final barHeight = maxSteps == 0
                      ? 4.0
                      : (d.steps / maxSteps) * chartHeight;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        isBest
                            ? const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 20)
                            : const SizedBox(height: 20),
                        Text('${d.steps}',
                            style: const TextStyle(fontSize: 9)),
                        const SizedBox(height: 2),
                        Container(
                          height: barHeight < 4 ? 4 : barHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isBest ? Colors.amber : Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('E').format(d.date),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gold bar + trophy = your best day this week',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}