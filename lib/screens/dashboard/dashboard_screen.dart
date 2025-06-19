import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/screens/expense/add_expense_screen.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/domain/budget_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:expense_tracker/screens/settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _monthFormat = DateFormat(
    'MMMM yyyy',
  );
  final DateFormat _dayFormat = DateFormat('d MMM');
  BudgetState? _currentMonthBudget;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _loadBudgetForSelectedMonth();
  }

  Future<void> _loadBudgetForSelectedMonth() async {
    final budget = await ref
        .read(budgetProvider.notifier)
        .getBudgetForMonth(
          _selectedDate.month,
          _selectedDate.year,
        );
    setState(() {
      _currentMonthBudget = budget;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadBudgetForSelectedMonth();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildBarChart(
    Map<Category, double> sums,
    String title,
  ) {
    final maxValue = sums.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final interval = (maxValue / 5).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups:
                  sums.entries.map((ent) {
                    final color =
                        Colors.primaries[ent.key.index %
                            Colors.primaries.length];
                    return BarChartGroupData(
                      x: ent.key.index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: ent.value,
                          color: color,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final cat =
                          Category.values[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                        ),
                        child: Text(
                          cat.displayName.substring(
                            0,
                            3,
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 4.0,
                        ),
                        child: Text(
                          _formatAmount(value),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor:
                      (group) => Colors.black54,
                  getTooltipItem: (
                    group,
                    groupIndex,
                    rod,
                    rodIndex,
                  ) {
                    final category =
                        Category.values[group.x.toInt()];
                    return BarTooltipItem(
                      '${category.displayName}\n${rod.toY.toStringAsFixed(2)} ${_currentMonthBudget?.currency.code ?? 'PLN'}',
                      const TextStyle(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(
    List<ExpenseState> transactions,
    String title,
  ) {
    final dailySums = <DateTime, double>{};
    for (var t in transactions) {
      final day = DateTime(
        t.date.year,
        t.date.month,
        t.date.day,
      );
      dailySums[day] =
          (dailySums[day] ?? 0) + t.baseAmount;
    }

    final sortedDays = dailySums.keys.toList()..sort();
    final maxValue = dailySums.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final interval = (maxValue / 5).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots:
                      sortedDays.map((day) {
                        return FlSpot(
                          day.day.toDouble(),
                          dailySums[day]!,
                        );
                      }).toList(),
                  isCurved: true,
                  color:
                      title.contains('Expenses')
                          ? Colors.red
                          : Colors.green,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final day = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        value.toInt(),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                        ),
                        child: Text(
                          _dayFormat.format(day),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 4.0,
                        ),
                        child: Text(
                          _formatAmount(value),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final filteredTransactions =
        transactions.where((t) {
          return t.date.year == _selectedDate.year &&
              t.date.month == _selectedDate.month;
        }).toList();

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

    return AppScaffold(
      title:
          'Dashboard (${_monthFormat.format(_selectedDate)})',
      bottomTabBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Expenses'),
          Tab(text: 'Incomes'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                    _loadBudgetForSelectedMonth();
                  },
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _monthFormat.format(_selectedDate),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                    _loadBudgetForSelectedMonth();
                  },
                ),
              ],
            ),
          ),
          if (_currentMonthBudget != null &&
              _currentMonthBudget!.isSet)
            _buildBudgetCard(
              _currentMonthBudget!,
              totalExpenses,
            )
          else
            _buildNoBudgetCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(
                  expenses,
                  totalExpenses,
                  'Expenses',
                  _currentMonthBudget,
                ),
                _buildTabContent(
                  incomes,
                  totalIncomes,
                  'Incomes',
                  _currentMonthBudget,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BudgetState budget,
    double totalExpenses,
  ) {
    final remainingBudget =
        budget.amount - totalExpenses;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'Budget: ${budget.amount.toStringAsFixed(2)} ${budget.currency.code}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalExpenses / budget.amount,
                backgroundColor: Colors.grey[200],
                color:
                    totalExpenses > budget.amount
                        ? Colors.red
                        : Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                'Remaining: ${remainingBudget.toStringAsFixed(2)} ${budget.currency.code}',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      remainingBudget < 0
                          ? Colors.red
                          : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoBudgetCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                'No budget set for this month.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const SettingsScreen(),
                    ),
                  );
                },
                child: const Text('Set Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<ExpenseState> transactions,
    double totalAmount,
    String title,
    BudgetState? budget,
  ) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    final Map<Category, double> sums = {};
    for (var t in transactions) {
      sums[t.category] =
          (sums[t.category] ?? 0) + t.baseAmount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total $title: ${totalAmount.toStringAsFixed(2)} ${budget?.currency.code ?? 'PLN'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (title == 'Expenses' &&
                      budget != null &&
                      budget.isSet)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Balance: ${(budget.amount - totalAmount).toStringAsFixed(2)} ${budget.currency.code}',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                (budget.amount -
                                            totalAmount) <
                                        0
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPieChart(
            sums,
            'Distribution of $title by Category',
          ),
          const SizedBox(height: 24),
          _buildLineChart(transactions, '$title Trend'),
          const SizedBox(height: 24),
          _buildBarChart(
            sums,
            'Comparison of $title across Categories',
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<Category, double> sums,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections:
                  sums.entries.map((ent) {
                    final color =
                        Colors.primaries[ent.key.index %
                            Colors.primaries.length];
                    return PieChartSectionData(
                      color: color,
                      value: ent.value,
                      title: '',
                      radius: 60,
                    );
                  }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              sums.entries.map((entry) {
                final color =
                    Colors.primaries[entry.key.index %
                        Colors.primaries.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.key.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${entry.value.toStringAsFixed(2)} ${_currentMonthBudget?.currency.code ?? 'PLN'})',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }
}
