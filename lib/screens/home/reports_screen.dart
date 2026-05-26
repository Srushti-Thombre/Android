import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/extensions.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  final Map<String, Color> categoryColors = {
    'Rent': Colors.blue,
    'Groceries': Colors.orange,
    'Transport': Colors.green,
    'Entertainment': Colors.purple,
    'Bills': Colors.red,
    'Shopping': Colors.pink,
    'Other': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = DateTime(now.year, now.month - 1, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Consumer3<AuthProvider, ExpenseProvider, IncomeProvider>(
        builder: (context, authProvider, expenseProvider, incomeProvider, _) {
          final userId = authProvider.currentUser?.uid;
          if (userId == null) {
            return const Center(child: Text('Please log in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change'),
                          onPressed: _selectDateRange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Summary Cards
                FutureBuilder<List<double>>(
                  future: Future.wait([
                    expenseProvider.getTotalExpenses(userId, startDate: _startDate, endDate: _endDate),
                    incomeProvider.getTotalIncome(userId, startDate: _startDate, endDate: _endDate),
                  ]),
                  builder: (context, snapshot) {
                    final totalExpenses = snapshot.data?[0] ?? 0.0;
                    final loggedIncome = snapshot.data?[1] ?? 0.0;
                    final user = context.read<UserProvider>().user;
                    final totalIncome = loggedIncome > 0 ? loggedIncome : (user?.monthlyIncome ?? 0.0);
                    final savings = totalIncome - totalExpenses;
                    final savingsPercentage =
                        totalIncome > 0 ? ((savings / totalIncome) * 100) : 0.0;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Income',
                                amount: totalIncome,
                                icon: Icons.trending_up,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Expenses',
                                amount: totalExpenses,
                                icon: Icons.trending_down,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Savings',
                                amount: savings,
                                icon: Icons.savings,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Savings %',
                                amount: savingsPercentage,
                                icon: Icons.percent,
                                color: Colors.purple,
                                isPercentage: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Category Breakdown with Pie Chart
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, double>>(
                  future: expenseProvider.getCategoryBreakdown(
                        userId,
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No expenses in this period',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      );
                    }

                    final categoryData = snapshot.data!;
                    return Column(
                      children: [
                        // Pie Chart
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: categoryData.entries
                                  .map(
                                    (entry) => PieChartSectionData(
                                      value: entry.value,
                                      title: '${(entry.value / categoryData.values.fold(0, (a, b) => a + b) * 100).toStringAsFixed(1)}%',
                                      color: categoryColors[entry.key] ?? Colors.grey,
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Category List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryData.length,
                          itemBuilder: (context, index) {
                            final entry =
                                categoryData.entries.toList()[index];
                            final total = categoryData.values.fold(
                              0.0,
                              (sum, val) => sum + val,
                            );
                            final percentage =
                                (entry.value / total * 100);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          entry.value.toCurrency(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: categoryColors[
                                                    entry.key],
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey
                                            .withValues(alpha: 0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(
                                          categoryColors[entry.key] ??
                                              Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}% of total',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Expenses
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<ExpenseModel>>(
                  future: _getRecentExpenses(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No transactions found',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      );
                    }

                    final expenses = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.take(10).length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (categoryColors[expense.category] ??
                                        Colors.grey)
                                    .withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: categoryColors[expense.category] ??
                                    Colors.grey,
                                size: 20,
                              ),
                            ),
                            title: Text(expense.category),
                            subtitle: Text(
                              '${_formatDate(expense.date)}${expense.note.isNotEmpty ? ' • ${expense.note}' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              expense.amount.toCurrency(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    bool isPercentage = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isPercentage
                  ? '${amount.toStringAsFixed(1)}%'
                  : amount.toCurrency(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ExpenseModel>> _getRecentExpenses(String userId) async {
    final allExpenses =
        await context.read<ExpenseProvider>().getAllUserExpenses(userId);
    final filtered = allExpenses
        .where((e) =>
            e.date.isAfter(_startDate) &&
            e.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getCategoryIcon(String category) {
    const icons = {
      'Rent': Icons.home,
      'Groceries': Icons.shopping_cart,
      'Transport': Icons.directions_car,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt_long,
      'Shopping': Icons.shopping_bag,
      'Other': Icons.more_horiz,
    };
    return icons[category] ?? Icons.category;
  }
}
