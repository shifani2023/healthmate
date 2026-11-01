import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/health_record_provider.dart';
import '../widgets/record_tile.dart';

class RecordListScreen extends StatelessWidget {
  const RecordListScreen({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<HealthRecordProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setSearchDate(HealthRecordProvider.formatDate(picked));
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final provider = context.read<HealthRecordProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete record?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.calories),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.deleteRecord(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordProvider>();
    final records = provider.records;
    final searching = provider.searchDate.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 1,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _pickDate(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              searching
                                  ? provider.searchDate
                                  : 'Search by date',
                              style: TextStyle(
                                fontSize: 15,
                                color: searching
                                    ? AppColors.textDark
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (searching)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => provider.setSearchDate(''),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${records.length} record${records.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No records found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return RecordTile(
                        record: record,
                        onDelete: () => _confirmDelete(context, record.id!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}