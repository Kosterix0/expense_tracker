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

    // Filtruj transakcje dla wybranego zakresu dat
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

    // Grupuj transakcje według kategorii
    final expenseByCategory = _groupByCategory(expenses);
    final incomeByCategory = _groupByCategory(incomes);

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Raport finansowy',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.Text(
                'Okres: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Podsumowanie'),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Typ', 'Kwota'],
                  [
                    'Wydatki',
                    '${totalExpenses.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                  ],
                  [
                    'Przychody',
                    '${totalIncomes.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                  ],
                  if (budget != null && budget.isSet)
                    [
                      'Pozostały budżet',
                      '${(budget.amount - totalExpenses).toStringAsFixed(2)} ${budget.currency.code}',
                    ],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Wydatki według kategorii',
                ),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Kategoria', 'Kwota', 'Procent'],
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
                child: pw.Text(
                  'Przychody według kategorii',
                ),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Kategoria', 'Kwota', 'Procent'],
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
                child: pw.Text('Lista transakcji'),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  [
                    'Data',
                    'Typ',
                    'Kategoria',
                    'Tytuł',
                    'Kwota',
                  ],
                  ...filteredTransactions.map(
                    (t) => [
                      DateFormat(
                        'dd.MM.yyyy',
                      ).format(t.date),
                      t.type == TransactionType.expense
                          ? 'Wydatek'
                          : 'Przychód',
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
      '${output.path}/raport_finansowy.pdf',
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

    // Grupuj transakcje według kategorii
    final expenseByCategory = _groupByCategory(expenses);
    final incomeByCategory = _groupByCategory(incomes);

    final List<List<dynamic>> csvData = [];

    // Nagłówek
    csvData.add(['Raport finansowy']);
    csvData.add([
      'Okres',
      '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
    ]);
    csvData.add([]);
    csvData.add(['Podsumowanie']);
    csvData.add(['Typ', 'Kwota']);
    csvData.add([
      'Wydatki',
      '${totalExpenses.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
    ]);
    csvData.add([
      'Przychody',
      '${totalIncomes.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
    ]);
    if (budget != null && budget.isSet) {
      csvData.add([
        'Pozostały budżet',
        '${(budget.amount - totalExpenses).toStringAsFixed(2)} ${budget.currency.code}',
      ]);
    }
    csvData.add([]);
    csvData.add(['Wydatki według kategorii']);
    csvData.add(['Kategoria', 'Kwota', 'Procent']);
    expenseByCategory.forEach((category, amount) {
      csvData.add([
        category.displayName,
        '${amount.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
        '${(amount / totalExpenses * 100).toStringAsFixed(1)}%',
      ]);
    });
    csvData.add([]);
    csvData.add(['Przychody według kategorii']);
    csvData.add(['Kategoria', 'Kwota', 'Procent']);
    incomeByCategory.forEach((category, amount) {
      csvData.add([
        category.displayName,
        '${amount.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
        '${(amount / totalIncomes * 100).toStringAsFixed(1)}%',
      ]);
    });
    csvData.add([]);
    csvData.add(['Lista transakcji']);
    csvData.add([
      'Data',
      'Typ',
      'Kategoria',
      'Tytuł',
      'Kwota',
      'Waluta',
      'Opis',
    ]);
    filteredTransactions.forEach((t) {
      csvData.add([
        DateFormat('dd.MM.yyyy').format(t.date),
        t.type == TransactionType.expense
            ? 'Wydatek'
            : 'Przychód',
        t.category.displayName,
        t.title,
        t.amount.toStringAsFixed(2),
        t.currency.code,
        t.description,
      ]);
    });

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/raport_finansowy.csv',
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
