import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../providers/health_provider.dart';
import '../widgets/background_image.dart';
import '../widgets/metric_card.dart';
import '../widgets/weekly_chart.dart';
import 'login_screen.dart';
import 'record_form_screen.dart';
import 'record_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Daily goals (set by the user, not medical advice)
  static const int stepsGoal = 10000;
  static const int caloriesGoal = 500;
  static const int waterGoal = 2000;

  Future<void> _openAddForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordFormScreen()),
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordListScreen()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      AuthController().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // A coloured message box
  Widget _messageBox(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Encouraging messages
  List<Widget> _buildMessages(int steps, int water) {
    final List<Widget> messages = [];

    if (water == 0) {
      messages.add(_messageBox(
        Icons.water_drop,
        "You haven't added any water today. Drink a glass of water now – your body will thank you!",
        Colors.blue,
      ));
    }
    if (steps == 0) {
      messages.add(_messageBox(
        Icons.directions_walk,
        'No steps recorded today. A short walk will make you feel great!',
        Colors.green,
      ));
    }
    if (water >= waterGoal && steps >= stepsGoal) {
      messages.add(_messageBox(
        Icons.celebration,
        'Amazing! You reached your water and steps goals today!',
        Colors.orange,
      ));
    }
    return messages;
  }

  // High score banner
  Widget _highScore(int steps, int bestSteps) {
    final isNewBest = steps > 0 && steps >= bestSteps;
    return _messageBox(
      Icons.emoji_events,
      isNewBest
          ? 'New high score! $steps steps is your best day ever!'
          : 'Your high score: $bestSteps steps in one day',
      Colors.amber.shade800,
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch = this screen refreshes whenever the shared notebook changes
    final health = context.watch<HealthProvider>();

    final steps = health.todaySteps;
    final calories = health.todayCalories;
    final water = health.todayWater;
    final todayLabel = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return BackgroundImage(
      asset: 'images/dashboard.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('HealthMate'),
          actions: [
            IconButton(
              onPressed: () => _openHistory(context),
              icon: const Icon(Icons.history),
              tooltip: 'History',
            ),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
            ),
          ],
        ),
        body: health.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<HealthProvider>().loadRecords(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Hello, ${AuthController.currentUser ?? 'there'}!',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('Today – $todayLabel',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ..._buildMessages(steps, water),
                    MetricCard(
                      title: 'Steps walked',
                      value: steps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk,
                      color: Colors.green,
                      goal: stepsGoal,
                      current: steps,
                    ),
                    MetricCard(
                      title: 'Calories burned',
                      value: calories.toString(),
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                      goal: caloriesGoal,
                      current: calories,
                    ),
                    MetricCard(
                      title: 'Water intake',
                      value: water.toString(),
                      unit: 'ml',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      goal: waterGoal,
                      current: water,
                    ),
                    const SizedBox(height: 8),
                    _highScore(steps, health.bestDaySteps),
                    WeeklyChart(days: health.weekTotals),
                    const SizedBox(height: 12),
                    const Text(
                      'Goals are set by you and are not medical advice.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _openAddForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Health Record'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openHistory(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('View Previous Records'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}