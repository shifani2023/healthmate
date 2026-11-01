import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/health_record_provider.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const int stepsGoal = 10000;
  static const int caloriesGoal = 600;
  static const int waterGoal = 2500;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _prettyDate(DateTime d) {
    return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  double _ratio(int value, int goal) {
    return (value / goal).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordProvider>();
    final topPadding = MediaQuery.of(context).padding.top;

    final stepsRatio = _ratio(provider.todaySteps, stepsGoal);
    final caloriesRatio = _ratio(provider.todayCalories, caloriesGoal);
    final waterRatio = _ratio(provider.todayWater, waterGoal);
    final overall = (stepsRatio + caloriesRatio + waterRatio) / 3;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Gradient header
          Container(
            padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'HealthMate',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _prettyDate(DateTime.now()),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Daily progress',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${(overall * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: overall,
                          minHeight: 8,
                          backgroundColor: Colors.white.withAlpha(60),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Activity cards
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's activity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                SummaryCard(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: Formatters.number(provider.todaySteps),
                  goalText: 'Goal: ${Formatters.number(stepsGoal)} steps',
                  progress: stepsRatio,
                  color: AppColors.steps,
                ),
                SummaryCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calories burned',
                  value: '${provider.todayCalories} kcal',
                  goalText: 'Goal: $caloriesGoal kcal',
                  progress: caloriesRatio,
                  color: AppColors.calories,
                ),
                SummaryCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Water intake',
                  value: '${Formatters.number(provider.todayWater)} ml',
                  goalText: 'Goal: ${Formatters.number(waterGoal)} ml',
                  progress: waterRatio,
                  color: AppColors.water,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}