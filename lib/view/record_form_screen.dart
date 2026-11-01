import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/health_record.dart';
import '../providers/health_record_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

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

  String? _validateNumber(String? value, String name, int max) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $name';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Enter a whole number';
    }
    if (number < 0) {
      return '$name cannot be negative';
    }
    if (number > max) {
      return '$name looks too high (max $max)';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final record = HealthRecord(
      date: HealthRecordProvider.formatDate(_selectedDate),
      steps: int.parse(_stepsController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      water: int.parse(_waterController.text.trim()),
    );

    context.read<HealthRecordProvider>().addRecord(record);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Text('Record added'),
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required String suffix,
  }) {
    OutlineInputBorder border(Color c, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      border: border(const Color(0xFFE5E7EB), 1),
      enabledBorder: border(const Color(0xFFE5E7EB), 1),
      focusedBorder: border(color, 2),
      errorBorder: border(AppColors.calories, 1),
      focusedErrorBorder: border(AppColors.calories, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Record',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Log your daily activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill in the details below and save.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),

            // Date selector
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        HealthRecordProvider.formatDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                label: 'Steps walked',
                hint: 'e.g. 7850',
                icon: Icons.directions_walk_rounded,
                color: AppColors.steps,
                suffix: 'steps',
              ),
              validator: (v) => _validateNumber(v, 'Steps', 100000),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                label: 'Calories burned',
                hint: 'e.g. 420',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.calories,
                suffix: 'kcal',
              ),
              validator: (v) => _validateNumber(v, 'Calories', 10000),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _waterController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                label: 'Water intake',
                hint: 'e.g. 2000',
                icon: Icons.water_drop_rounded,
                color: AppColors.water,
                suffix: 'ml',
              ),
              validator: (v) => _validateNumber(v, 'Water', 10000),
            ),
            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Save Record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}