import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final int? goal; // optional daily goal
  final int current; // today's number, used for the goal bar

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.color = Colors.green,
    this.goal,
    this.current = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal != null && goal! > 0;
    final progress = hasGoal ? (current / goal!).clamp(0.0, 1.0).toDouble() : 0.0;
    final reached = hasGoal && current >= goal!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 5),
                  Text(
                    '$value $unit',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasGoal) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reached
                          ? 'Goal reached – well done!'
                          : 'Goal: $goal $unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: reached ? color : Colors.black54,
                        fontWeight:
                            reached ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (reached) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}