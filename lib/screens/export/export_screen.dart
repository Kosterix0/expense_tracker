import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/export_service.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/app.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/services/budget_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExportScreen> createState() =>
      _ExportScreenState();
}

class _ExportScreenState
    extends ConsumerState<ExportScreen> {
  DateTime _startDate = DateTime.now().subtract(
    const Duration(days: 30),
  );
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  Future<void> _selectStartDate(
    BuildContext context,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate.add(
            const Duration(days: 1),
          );
        }
      });
    }
  }

  Future<void> _selectEndDate(
    BuildContext context,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _exportData(String format) async {
    setState(() => _isExporting = true);
    try {
      final transactions = ref.read(transactionProvider);
      final budgetNotifier = ref.read(
        budgetProvider.notifier,
      );
      final budget = await budgetNotifier
          .getBudgetForMonth(
            DateTime.now().month,
            DateTime.now().year,
          );

      final file =
          format == 'pdf'
              ? await ExportService.generatePdf(
                transactions: transactions,
                startDate: _startDate,
                endDate: _endDate,
                budget: budget,
              )
              : await ExportService.generateCsv(
                transactions: transactions,
                startDate: _startDate,
                endDate: _endDate,
                budget: budget,
              );

      await ExportService.openFile(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully exported data to $format',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Export Data',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select date range to export:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('From:'),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed:
                          () =>
                              _selectStartDate(context),
                      child: Text(
                        DateFormat(
                          'dd.MM.yyyy',
                        ).format(_startDate),
                      ),
                    ),
                    const Spacer(),
                    const Text('To:'),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed:
                          () => _selectEndDate(context),
                      child: Text(
                        DateFormat(
                          'dd.MM.yyyy',
                        ).format(_endDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Select export format:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                      ),
                      label: const Text('PDF'),
                      onPressed:
                          _isExporting
                              ? null
                              : () => _exportData('pdf'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.table_chart,
                      ),
                      label: const Text('CSV'),
                      onPressed:
                          _isExporting
                              ? null
                              : () => _exportData('csv'),
                    ),
                  ],
                ),
                if (_isExporting)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
