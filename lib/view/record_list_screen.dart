import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';
import '../widgets/background_image.dart';
import 'record_detail_screen.dart';
import 'record_form_screen.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  // These only control how this screen looks (calendar and sorting)
  DateTime _focusedDay = DateTime.now();
  DateTime? _filterDate;
  CalendarFormat _format = CalendarFormat.twoWeeks;
  bool _newestFirst = true;

  // True when the day is after today (records can't be added for the future)
  bool _isFutureDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(d.year, d.month, d.day).isAfter(today);
  }

  // Sort by date, then by id (newest first or oldest first)
  List<HealthRecord> _sorted(List<HealthRecord> list) {
    final copy = List<HealthRecord>.from(list);
    copy.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      final result = byDate != 0 ? byDate : (a.id ?? 0).compareTo(b.id ?? 0);
      return _newestFirst ? -result : result;
    });
    return copy;
  }

  // Add a record for the day that is selected on the calendar (a missed day)
  Future<void> _addRecordForDay() async {
    final day = _filterDate;
    if (day == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(
          initialDate: DateTime(day.year, day.month, day.day),
        ),
      ),
    );
  }

  Future<void> _editRecord(HealthRecord record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(record: record),
      ),
    );
  }

  void _openDetails(HealthRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordDetailScreen(record: record),
      ),
    );
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    final health = context.read<HealthProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && record.id != null) {
      try {
        await health.deleteRecord(record.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
      } catch (e) {
        debugPrint('Could not delete record: $e');
      }
    }
  }

  Widget _recordCard(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () => _openDetails(record),
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

  // The "add record for this day" button (or a note for future days)
  Widget _addForDaySection() {
    final day = _filterDate!;

    if (_isFutureDay(day)) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          "You can't add records for future days.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: _addRecordForDay,
          icon: const Icon(Icons.add),
          label: Text(
              'Add record for ${DateFormat('dd MMM yyyy').format(day)}'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch = this screen refreshes whenever the shared notebook changes
    final health = context.watch<HealthProvider>();

    final shown = _sorted(
      _filterDate == null
          ? health.records
          : health.recordsForDate(_filterDate!),
    );

    return BackgroundImage(
      asset: 'images/history.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Health History'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
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
                eventLoader: (day) => health.recordsForDate(day),
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
              padding: const EdgeInsets.only(top: 8),
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
                      onPressed: () => setState(() => _filterDate = null),
                      icon: const Icon(Icons.clear),
                      label: const Text('Show all'),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _newestFirst = !_newestFirst),
                icon: Icon(
                    _newestFirst ? Icons.arrow_downward : Icons.arrow_upward),
                label: Text(_newestFirst ? 'Newest first' : 'Oldest first'),
              ),
            ),
            if (_filterDate != null) _addForDaySection(),
            if (health.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.event_busy,
                        size: 48, color: Colors.black45),
                    const SizedBox(height: 12),
                    Text(_filterDate == null
                        ? 'No health records found.'
                        : 'No records for this day yet.'),
                  ],
                ),
              )
            else
              ...shown.map(_recordCard),
          ],
        ),
      ),
    );
  }
}