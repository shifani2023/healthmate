import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/health_record.dart';
import '../widgets/banner_image.dart';

class RecordFormScreen extends StatefulWidget {
  final HealthRecord? record;

  const RecordFormScreen({super.key, this.record});

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = HealthController();

  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _selectedDate = record == null
        ? DateTime.now()
        : DateTime.parse(record.date);

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

    setState(() => _isSaving = true);

    final record = HealthRecord(
      id: widget.record?.id,
      date: _dateValue,
      steps: int.parse(_stepsController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      waterMl: int.parse(_waterController.text.trim()),
    );

    try {
      if (widget.record == null) {
        await _controller.addRecord(record);
      } else {
        await _controller.updateRecord(record);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save record: $e')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Health Record' : 'Add Health Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BannerImage(
                asset: isEditing ? 'images/image.jpg' : 'images/addrecord.jpg',
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Record date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Steps walked',
                  prefixIcon: Icon(Icons.directions_walk, color: Colors.green),
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
    );
  }
}