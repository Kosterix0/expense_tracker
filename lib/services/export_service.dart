import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/budget_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/widgets.dart';
import 'package:universal_html/html.dart'
    show Blob, Url;

class ExportService {
  static Future<Uint8List> _generatePdfBytes({
    required List<ExpenseState> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetState? budget,
  }) async {
    final pdf = pw.Document();

    final filteredTransactions =
        transactions
            .where(
              (t) =>
                  t.date.isAfter(
                    startDate.subtract(
                      const Duration(days: 1),
                    ),
                  ) &&
                  t.date.isBefore(
                    endDate.add(const Duration(days: 1)),
                  ),
            )
            .toList();

    final expenses =
        filteredTransactions
            .where(
              (t) => t.type == TransactionType.expense,
            )
            .toList();
    final incomes =
        filteredTransactions
            .where(
              (t) => t.type == TransactionType.income,
            )
            .toList();

    final totalExpenses = expenses.fold<double>(
      0,
      (sum, t) => sum + t.baseAmount,
    );
    final totalIncomes = incomes.fold<double>(
      0,
      (sum, t) => sum + t.baseAmount,
    );

    final expenseByCategory = _groupByCategory(expenses);
    final incomeByCategory = _groupByCategory(incomes);

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Financial Report',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.Text(
                'Period: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Summary'),
              ),
              TableHelper.fromTextArray(
                context: context,
                data: [
                  ['Type', 'Amount'],
                  [
                    'Expenses',
                    '${totalExpenses.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                  ],
                  [
                    'Incomes',
                    '${totalIncomes.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                  ],
                  if (budget != null && budget.isSet)
                    [
                      'Remaining Budget',
                      '${(budget.amount - totalExpenses).toStringAsFixed(2)} ${budget.currency.code}',
                    ],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Expenses by Category'),
              ),
              TableHelper.fromTextArray(
                context: context,
                data: [
                  ['Category', 'Amount', 'Percentage'],
                  ...expenseByCategory.entries.map(
                    (e) => [
                      e.key.displayName,
                      '${e.value.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                      '${(e.value / totalExpenses * 100).toStringAsFixed(1)}%',
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Incomes by Category'),
              ),
              TableHelper.fromTextArray(
                context: context,
                data: [
                  ['Category', 'Amount', 'Percentage'],
                  ...incomeByCategory.entries.map(
                    (e) => [
                      e.key.displayName,
                      '${e.value.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                      '${(e.value / totalIncomes * 100).toStringAsFixed(1)}%',
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Transaction List'),
              ),
              TableHelper.fromTextArray(
                context: context,
                data: [
                  [
                    'Date',
                    'Type',
                    'Category',
                    'Title',
                    'Amount',
                  ],
                  ...filteredTransactions.map(
                    (t) => [
                      DateFormat(
                        'dd.MM.yyyy',
                      ).format(t.date),
                      t.type == TransactionType.expense
                          ? 'Expense'
                          : 'Income',
                      t.category.displayName,
                      t.title,
                      '${t.amount.toStringAsFixed(2)} ${t.currency.code}',
                    ],
                  ),
                ],
              ),
            ],
      ),
    );

    return await pdf.save();
  }

  static Future<String> _generateCsvString({
    required List<ExpenseState> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetState? budget,
  }) async {
    final filteredTransactions =
        transactions
            .where(
              (t) =>
                  t.date.isAfter(
                    startDate.subtract(
                      const Duration(days: 1),
                    ),
                  ) &&
                  t.date.isBefore(
                    endDate.add(const Duration(days: 1)),
                  ),
            )
            .toList();

    final expenses =
        filteredTransactions
            .where(
              (t) => t.type == TransactionType.expense,
            )
            .toList();
    final incomes =
        filteredTransactions
            .where(
              (t) => t.type == TransactionType.income,
            )
            .toList();

    final totalExpenses = expenses.fold<double>(
      0,
      (sum, t) => sum + t.baseAmount,
    );
    final totalIncomes = incomes.fold<double>(
      0,
      (sum, t) => sum + t.baseAmount,
    );

    final expenseByCategory = _groupByCategory(expenses);
    final incomeByCategory = _groupByCategory(incomes);

    final List<List<dynamic>> csvData = [];

    csvData.add(['Financial Report']);
    csvData.add([
      'Period',
      '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
    ]);
    csvData.add([]);
    csvData.add(['Summary']);
    csvData.add(['Type', 'Amount']);
    csvData.add([
      'Expenses',
      '${totalExpenses.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
    ]);
    csvData.add([
      'Incomes',
      '${totalIncomes.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
    ]);
    if (budget != null && budget.isSet) {
      csvData.add([
        'Remaining Budget',
        '${(budget.amount - totalExpenses).toStringAsFixed(2)} ${budget.currency.code}',
      ]);
    }
    csvData.add([]);
    csvData.add(['Expenses by Category']);
    csvData.add(['Category', 'Amount', 'Percentage']);
    expenseByCategory.forEach((category, amount) {
      csvData.add([
        category.displayName,
        '${amount.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
        '${(amount / totalExpenses * 100).toStringAsFixed(1)}%',
      ]);
    });
    csvData.add([]);
    csvData.add(['Incomes by Category']);
    csvData.add(['Category', 'Amount', 'Percentage']);
    incomeByCategory.forEach((category, amount) {
      csvData.add([
        category.displayName,
        '${amount.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
        '${(amount / totalIncomes * 100).toStringAsFixed(1)}%',
      ]);
    });
    csvData.add([]);
    csvData.add(['Transaction List']);
    csvData.add([
      'Date',
      'Type',
      'Category',
      'Title',
      'Amount',
      'Currency',
      'Description',
    ]);
    for (var t in filteredTransactions) {
      csvData.add([
        DateFormat('dd.MM.yyyy').format(t.date),
        t.type == TransactionType.expense
            ? 'Expense'
            : 'Income',
        t.category.displayName,
        t.title,
        t.amount.toStringAsFixed(2),
        t.currency.code,
        t.description,
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  static Future<File> generatePdf({
    required List<ExpenseState> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetState? budget,
  }) async {
    final bytes = await _generatePdfBytes(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
    );

    if (kIsWeb) {
      return File.fromRawPath(bytes);
    } else {
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/financial_report.pdf',
      );
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  static Future<File> generateCsv({
    required List<ExpenseState> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetState? budget,
  }) async {
    final csvString = await _generateCsvString(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
    );

    if (kIsWeb) {
      return File.fromRawPath(
        Uint8List.fromList(csvString.codeUnits),
      );
    } else {
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/financial_report.csv',
      );
      await file.writeAsString(csvString);
      return file;
    }
  }

  static Future<void> exportData({
    required String format,
    required List<ExpenseState> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetState? budget,
  }) async {
    try {
      if (kIsWeb) {
        if (format == 'pdf') {
          final bytes = await _generatePdfBytes(
            transactions: transactions,
            startDate: startDate,
            endDate: endDate,
            budget: budget,
          );
          _downloadFileWeb(
            bytes,
            'financial_report.pdf',
          );
        } else {
          final csvString = await _generateCsvString(
            transactions: transactions,
            startDate: startDate,
            endDate: endDate,
            budget: budget,
          );
          _downloadFileWeb(
            Uint8List.fromList(csvString.codeUnits),
            'financial_report.csv',
          );
        }
      } else {
        final file =
            format == 'pdf'
                ? await generatePdf(
                  transactions: transactions,
                  startDate: startDate,
                  endDate: endDate,
                  budget: budget,
                )
                : await generateCsv(
                  transactions: transactions,
                  startDate: startDate,
                  endDate: endDate,
                  budget: budget,
                );
        await openFile(file);
      }
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  static void _downloadFileWeb(
    Uint8List bytes,
    String fileName,
  ) {
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);

    Url.revokeObjectUrl(url);
  }

  static Map<Category, double> _groupByCategory(
    List<ExpenseState> transactions,
  ) {
    final Map<Category, double> result = {};
    for (var t in transactions) {
      result[t.category] =
          (result[t.category] ?? 0) + t.baseAmount;
    }
    return result;
  }

  static Future<void> openFile(File file) async {
    if (!kIsWeb) {
      await OpenFile.open(file.path);
    }
  }
}
