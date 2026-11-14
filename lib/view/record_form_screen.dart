import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';
import '../widgets/background_image.dart';

class RecordFormScreen extends StatefulWidget {
  final HealthRecord? record;
  final DateTime? initialDate; // used when adding for a missed day

  const RecordFormScreen({super.key, this.record, this.initialDate});

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;

    if (record != null) {
      _selectedDate = DateTime.parse(record.date);
    } else if (widget.initialDate != null) {
      final d = widget.initialDate!;
      _selectedDate = DateTime(d.year, d.month, d.day);
    } else {
      _selectedDate = DateTime.now();
    }

    _stepsController = TextEditingController(
      text: record?.steps.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: record?.calories.toString() ?? '',
    );
    _waterController = TextEditingController(
      text: record?.waterMl.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  String get _dateValue => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    // read = just use the shared notebook (no need to refresh this screen)
    final health = context.read<HealthProvider>();

    setState(() => _isSaving = true);

    final isEditing = widget.record != null;

    final record = HealthRecord(
      id: widget.record?.id,
      date: _dateValue,
      steps: int.parse(_stepsController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      waterMl: int.parse(_waterController.text.trim()),
    );

    try {
      if (isEditing) {
        await health.updateRecord(record);
      } else {
        await health.addRecord(record);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Record updated successfully'
              : 'Record added successfully'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      // Technical details go to the Terminal only
      debugPrint('Could not save record: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the record. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $field';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number < 0) {
      return 'Enter a valid non-negative whole number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return BackgroundImage(
      asset: isEditing ? 'images/image.jpg' : 'images/addrecord.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(isEditing ? 'Edit Health Record' : 'Add Health Record'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Record date'),
                  subtitle:
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  // No calendar icon and no tapping when editing
                  trailing: isEditing ? null : const Icon(Icons.calendar_month),
                  onTap: isEditing ? null : _pickDate,
                ),
                if (isEditing)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      "The date can't be changed while editing.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                TextFormField(
                  controller: _stepsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Steps walked',
                    prefixIcon:
                        Icon(Icons.directions_walk, color: Colors.green),
                  ),
                  validator: (v) => _validateNumber(v, 'steps'),
                ),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories burned (kcal)',
                    prefixIcon:
                        Icon(Icons.local_fire_department, color: Colors.red),
                  ),
                  validator: (v) => _validateNumber(v, 'calories'),
                ),
                TextFormField(
                  controller: _waterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Water intake (ml)',
                    prefixIcon: Icon(Icons.water_drop, color: Colors.blue),
                  ),
                  validator: (v) => _validateNumber(v, 'water intake'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  child: Text(_isSaving ? 'Saving...' : 'Save Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}