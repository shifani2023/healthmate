import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/daily_total.dart';
import '../models/health_record.dart';
import '../widgets/background_image.dart';
import '../widgets/metric_card.dart';
import '../widgets/weekly_chart.dart';
import 'record_form_screen.dart';
import 'record_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Daily goals (set by the user, not medical advice)
  static const int stepsGoal = 10000;
  static const int caloriesGoal = 500;
  static const int waterGoal = 2000;

  final _controller = HealthController();
  List<HealthRecord> _todayRecords = [];
  List<DailyTotal> _week = [];
  int _bestSteps = 0;
  bool _isLoading = true;

  int get _steps =>
      _todayRecords.fold(0, (sum, item) => sum + item.steps);
  int get _calories =>
      _todayRecords.fold(0, (sum, item) => sum + item.calories);
  int get _water =>
      _todayRecords.fold(0, (sum, item) => sum + item.waterMl);

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    try {
      final records = await _controller.getTodayRecords();
      final week = await _controller.getWeekTotals();
      final best = await _controller.getBestDaySteps();
      if (!mounted) return;
      setState(() {
        _todayRecords = records;
        _week = week;
        _bestSteps = best;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sorry, we could not load your data. Please try again. ($e)'),
        ),
      );
    }
  }

  Future<void> _openAddForm() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RecordFormScreen()),
    );
    if (changed == true) await _loadToday();
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordListScreen()),
    );
    await _loadToday();
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
  List<Widget> _buildMessages() {
    final List<Widget> messages = [];

    if (_water == 0) {
      messages.add(_messageBox(
        Icons.water_drop,
        "You haven't added any water today. Drink a glass of water now – your body will thank you!",
        Colors.blue,
      ));
    }
    if (_steps == 0) {
      messages.add(_messageBox(
        Icons.directions_walk,
        'No steps recorded today. A short walk will make you feel great!',
        Colors.green,
      ));
    }
    if (_water >= waterGoal && _steps >= stepsGoal) {
      messages.add(_messageBox(
        Icons.celebration,
        'Amazing! You reached your water and steps goals today!',
        Colors.orange,
      ));
    }
    return messages;
  }

  // High score banner
  Widget _highScore() {
    final isNewBest = _steps > 0 && _steps >= _bestSteps;
    return _messageBox(
      Icons.emoji_events,
      isNewBest
          ? 'New high score! $_steps steps is your best day ever!'
          : 'Your high score: $_bestSteps steps in one day',
      Colors.amber.shade800,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _openHistory,
              icon: const Icon(Icons.history),
              tooltip: 'History',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadToday,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Today – $todayLabel',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ..._buildMessages(),
                    MetricCard(
                      title: 'Steps walked',
                      value: _steps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk,
                      color: Colors.green,
                      goal: stepsGoal,
                      current: _steps,
                    ),
                    MetricCard(
                      title: 'Calories burned',
                      value: _calories.toString(),
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                      goal: caloriesGoal,
                      current: _calories,
                    ),
                    MetricCard(
                      title: 'Water intake',
                      value: _water.toString(),
                      unit: 'ml',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      goal: waterGoal,
                      current: _water,
                    ),
                    const SizedBox(height: 8),
                    _highScore(),
                    WeeklyChart(days: _week),
                    const SizedBox(height: 12),
                    const Text(
                      'Goals are set by you and are not medical advice.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openAddForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Health Record'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openHistory,
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