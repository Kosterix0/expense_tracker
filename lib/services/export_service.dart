import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/budget_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<File> generatePdf({
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
    ;

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
              pw.Table.fromTextArray(
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
              pw.Table.fromTextArray(
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
              pw.Table.fromTextArray(
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
              pw.Table.fromTextArray(
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

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/financial_report.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateCsv({
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
    filteredTransactions.forEach((t) {
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
    });

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/financial_report.csv',
    );
    await file.writeAsString(
      const ListToCsvConverter().convert(csvData),
    );
    return file;
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
    await OpenFile.open(file.path);
  }
}
