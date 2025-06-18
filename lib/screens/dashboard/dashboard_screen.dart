import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/auth/sign_google.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/screens/expense/add_expense_screen.dart';
import 'package:expense_tracker/app.dart';

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
  final GoogleAuthService _authService =
      GoogleAuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value >= 1000)
      return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final expenses =
        transactions
            .where(
              (t) => t.type == TransactionType.expense,
            )
            .toList();
    final incomes =
        transactions
            .where(
              (t) => t.type == TransactionType.income,
            )
            .toList();

    return AppScaffold(
      title: 'Dashboard',

      bottomTabBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Expenses'),
          Tab(text: 'Incomes'),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(expenses, 'Expenses'),
          _buildTabContent(incomes, 'Incomes'),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabContent(
    List<ExpenseState> transactions,
    String title,
  ) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final Map<Category, double> sums = {};
    for (var t in transactions) {
      sums[t.category] =
          (sums[t.category] ?? 0) + t.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pie Chart
          _buildPieChart(
            sums,
            'Category Distribution for $title',
          ),
          const SizedBox(height: 24),
          // Bar Chart
          _buildBarChart(
            sums,
            'Category Comparison for $title',
          ),
          const SizedBox(height: 24),
          // Line Chart
          _buildLineChart(
            transactions,
            '$title Over Time',
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<Category, double> sums,
    String title,
  ) {
    final List<PieChartSectionData> sections =
        sums.entries.map((ent) {
          final color =
              Colors.primaries[ent.key.index %
                  Colors.primaries.length];
          return PieChartSectionData(
            color: color,
            value: ent.value,
            title: '${_formatAmount(ent.value)} zł',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    Map<Category, double> sums,
    String title,
  ) {
    final List<BarChartGroupData> barGroups =
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
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
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
                    getTitlesWidget: (value, meta) {
                      return Text(_formatAmount(value));
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
                      '${category.displayName}\n${_formatAmount(rod.toY)} zł',
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
    final Map<DateTime, double> dailySums = {};
    for (var t in transactions) {
      final date = DateTime(
        t.date.year,
        t.date.month,
        t.date.day,
      );
      dailySums[date] =
          (dailySums[date] ?? 0) + t.amount;
    }

    final sortedDates = dailySums.keys.toList()..sort();
    final List<FlSpot> spots =
        sortedDates.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            dailySums[entry.value]!,
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < sortedDates.length) {
                        final date =
                            sortedDates[value.toInt()];
                        return Text(
                          DateFormat(
                            'dd.MM',
                          ).format(date),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(_formatAmount(value));
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
}
