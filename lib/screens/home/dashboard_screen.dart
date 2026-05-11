import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/dashboard/summary_card.dart';
import '../../widgets/expense/expense_card.dart';
import '../../widgets/charts/pie_chart_widget.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final Map<String, IconData> categoryIcons = {
    'Rent': Icons.home,
    'Groceries': Icons.shopping_cart,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Shopping': Icons.shopping_bag,
    'Other': Icons.more_horiz,
  };

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
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.uid;
      if (userId != null) {
        // Initialize expense provider with user ID (all expenses in memory)
        context.read<ExpenseProvider>().initializeUser(userId);
        context.read<UserProvider>().loadUserProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final userId = authProvider.currentUser?.uid;
          if (userId == null) return const LoadingIndicator();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Monthly Summary
                Consumer2<UserProvider, ExpenseProvider>(
                  builder: (context, userProvider, expenseProvider, _) {
                    final user = userProvider.user;
                    final totalIncome = user?.monthlyIncome ?? 0.0;
                    final totalExpenses = expenseProvider.totalExpenses;
                    final savings = totalIncome - totalExpenses;

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'Income',
                                  value: totalIncome.toCurrency(),
                                  color: Colors.green,
                                  icon: Icons.trending_up,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Expenses',
                                  value: totalExpenses.toCurrency(),
                                  color: Colors.red,
                                  icon: Icons.trending_down,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SummaryCard(
                            title: 'Savings',
                            value: savings.toCurrency(),
                            color: Colors.blue,
                            icon: Icons.savings,
                            subtitle: '${((savings / totalIncome * 100).toStringAsFixed(1))}% of income',
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Quick Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExpenseScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Expense'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AnalyticsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Analytics'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Navigation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      setState(() => _selectedTabIndex = index);
                    },
                    tabs: const [
                      Tab(text: 'Overview', icon: Icon(Icons.pie_chart)),
                      Tab(text: 'History', icon: Icon(Icons.history)),
                      Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
                    ],
                  ),
                ),

                // Tab Content
                Consumer<ExpenseProvider>(
                  builder: (context, expenseProvider, _) {
                    return SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Overview Tab
                          _buildOverviewTab(expenseProvider),
                          // History Tab
                          _buildHistoryTab(expenseProvider, userId),
                          // Insights Tab
                          _buildInsightsTab(expenseProvider),
                        ],
                      ),
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

  Widget _buildOverviewTab(ExpenseProvider expenseProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (expenseProvider.categoryBreakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          else
            PieChartWidget(
              data: expenseProvider.categoryBreakdown,
              categoryColors: categoryColors,
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ExpenseProvider expenseProvider, String userId) {
    if (expenseProvider.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No expense history',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenseProvider.expenses.length,
      itemBuilder: (context, index) {
        final expense = expenseProvider.expenses[index];
        return ExpenseCard(
          category: expense.category,
          amount: expense.amount,
          date: expense.date,
          note: expense.note,
          categoryIcon: Icon(
            categoryIcons[expense.category] ?? Icons.category,
            color: categoryColors[expense.category] ?? Colors.grey,
          ),
          onDeletePressed: () {
            _showDeleteDialog(context, userId, expense);
          },
        );
      },
    );
  }

  Widget _buildInsightsTab(ExpenseProvider expenseProvider) {
    final user = context.read<UserProvider>().user;
    final totalIncome = user?.monthlyIncome ?? 0.0;
    final totalExpenses = expenseProvider.totalExpenses;
    final savings = totalIncome - totalExpenses;
    final expenseRatio = totalIncome > 0 ? (totalExpenses / totalIncome * 100) : 0.0;

    String getStatus() {
      if (expenseRatio > 100) return 'Budget Exceeded!';
      if (expenseRatio > 80) return 'High Spending';
      if (expenseRatio > 50) return 'Moderate Spending';
      return 'Good Savings';
    }

    String getMessage() {
      if (expenseRatio > 100) return 'You are overspending this month!';
      if (expenseRatio > 80) return 'Be careful, you are spending too much.';
      if (expenseRatio > 50) return 'Your spending is moderate. Keep tracking!';
      return 'Great job! You are saving well.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Card(
            color: _getStatusColor(expenseRatio).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(expenseRatio),
                        color: _getStatusColor(expenseRatio),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getStatus(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Spending: ${expenseRatio.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(getMessage()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (expenseProvider.categoryBreakdown.isNotEmpty) ...[
            Text(
              'Top Spending Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildTopCategoryWidget(expenseProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildTopCategoryWidget(ExpenseProvider expenseProvider) {
    final topCategory = expenseProvider.categoryBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColors[topCategory.key]?.withOpacity(0.2),
              ),
              child: Icon(
                categoryIcons[topCategory.key],
                color: categoryColors[topCategory.key],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topCategory.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topCategory.value.toCurrency(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: categoryColors[topCategory.key],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete this ${expense.category} expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete expense instantly (no async)
              context.read<ExpenseProvider>().deleteExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double expenseRatio) {
    if (expenseRatio > 100) return Colors.red;
    if (expenseRatio > 80) return Colors.orange;
    if (expenseRatio > 50) return Colors.yellow;
    return Colors.green;
  }

  IconData _getStatusIcon(double expenseRatio) {
    if (expenseRatio > 100) return Icons.trending_up;
    if (expenseRatio > 80) return Icons.warning;
    if (expenseRatio > 50) return Icons.info;
    return Icons.thumb_up;
  }
}
