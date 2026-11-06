import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/health_controller.dart';
import '../models/health_record.dart';
import '../widgets/banner_image.dart';
import 'record_form_screen.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final _controller = HealthController();

  List<HealthRecord> _allRecords = []; // used for the calendar dots
  List<HealthRecord> _records = []; // the list shown under the calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _filterDate;
  CalendarFormat _format = CalendarFormat.twoWeeks;
  bool _isLoading = true;

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);

    final all = await _controller.getAllRecords();
    final shown = _filterDate == null
        ? all
        : await _controller.getRecordsByDate(_fmt(_filterDate!));

    if (!mounted) return;
    setState(() {
      _allRecords = all;
      _records = shown;
      _isLoading = false;
    });
  }

  List<HealthRecord> _recordsForDay(DateTime day) {
    final key = _fmt(day);
    return _allRecords.where((r) => r.date == key).toList();
  }

  Future<void> _editRecord(HealthRecord record) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(record: record),
      ),
    );
    if (changed == true) await _loadRecords();
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && record.id != null) {
      await _controller.deleteRecord(record.id!);
      await _loadRecords();
    }
  }

  Widget _recordCard(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(DateFormat('dd MMM yyyy')
            .format(DateTime.parse(record.date))),
        subtitle: Text(
          'Steps: ${record.steps} | '
          'Calories: ${record.calories} kcal | '
          'Water: ${record.waterMl} ml',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editRecord(record);
            if (value == 'delete') _deleteRecord(record);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health History')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const BannerImage(asset: 'images/history.jpg', height: 110),
          const SizedBox(height: 8),
          Card(
            child: TableCalendar<HealthRecord>(
              firstDay: DateTime(2020),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              calendarFormat: _format,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.twoWeeks: '2 weeks',
                CalendarFormat.week: 'Week',
              },
              selectedDayPredicate: (day) =>
                  _filterDate != null && isSameDay(day, _filterDate),
              eventLoader: _recordsForDay,
              headerStyle: const HeaderStyle(titleCentered: true),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _filterDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadRecords();
              },
              onFormatChanged: (format) {
                setState(() => _format = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _filterDate == null
                        ? 'Showing all records (tap a day to filter)'
                        : 'Records for ${DateFormat('dd MMM yyyy').format(_filterDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_filterDate != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _filterDate = null);
                      _loadRecords();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Show all'),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: BannerImage(asset: 'images/image.jpg', height: 120),
                  ),
                  SizedBox(height: 12),
                  Text('No health records found.'),
                ],
              ),
            )
          else
            ..._records.map(_recordCard),
        ],
      ),
    );
  }
}