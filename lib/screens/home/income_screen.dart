import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/income_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/extensions.dart';
import '../../utils/validators.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final Map<String, IconData> sourceIcons = {
    'Salary': Icons.work,
    'Freelance': Icons.laptop,
    'Bonus': Icons.card_giftcard,
    'Business': Icons.store,
    'Other': Icons.payments,
  };

  final List<String> sources = const [
    'Salary',
    'Freelance',
    'Bonus',
    'Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIncome();
    });
  }

  Future<void> _initializeIncome() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId != null) {
      await context.read<IncomeProvider>().initializeUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Income Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddIncomeDialog,
          ),
        ],
      ),
      body: Consumer2<AuthProvider, IncomeProvider>(
        builder: (context, authProvider, incomeProvider, _) {
          final userId = authProvider.currentUser?.uid;
          if (userId == null) {
            return const Center(child: Text('Please log in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => incomeProvider.setSelectedMonth(
                            DateTime(incomeProvider.selectedMonth.year, incomeProvider.selectedMonth.month - 1, 1),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _monthLabel(incomeProvider.selectedMonth),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total income: ${incomeProvider.totalIncome.toCurrency()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => incomeProvider.setSelectedMonth(
                            DateTime(incomeProvider.selectedMonth.year, incomeProvider.selectedMonth.month + 1, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _showAddIncomeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Income'),
                  ),
                ),
                const SizedBox(height: 16),
                if (incomeProvider.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No income entries for this month',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = incomeProvider.transactions[index];
                      final icon = sourceIcons[transaction.source] ?? Icons.payments;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.15),
                            child: Icon(icon, color: Colors.green),
                          ),
                          title: Text(transaction.source),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Formatters.formatDate(transaction.date)),
                              if (transaction.note.isNotEmpty) Text(transaction.note),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                transaction.amount.toCurrency(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(transaction.id),
                              ),
                            ],
                          ),
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

  Future<void> _showAddIncomeDialog() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedSource = sources.first;
    DateTime selectedDate = DateTime.now();
    final authProvider = context.read<AuthProvider>();

    final result = await showDialog<_IncomeEntryResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Income'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    validator: Validators.validateAmount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSource,
                    items: sources
                        .map(
                          (source) => DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedSource = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Source',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(Formatters.formatDate(selectedDate)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                Navigator.pop(
                  dialogContext,
                  _IncomeEntryResult(
                    amount: double.parse(amountController.text.trim()),
                    source: selectedSource,
                    date: selectedDate,
                    note: noteController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    amountController.dispose();
    noteController.dispose();

    if (result == null || !mounted) {
      return;
    }

    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      return;
    }

    try {
      await context.read<IncomeProvider>().addIncomeTransaction(
            userId: userId,
            source: result.source,
            amount: result.amount,
            date: result.date,
            note: result.note,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding income: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(String transactionId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Income?'),
        content: const Text('Are you sure you want to delete this income entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await context.read<IncomeProvider>().deleteIncomeTransaction(transactionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting income: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _monthLabel(DateTime month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[month.month - 1]} ${month.year}';
  }
}

class _IncomeEntryResult {
  final double amount;
  final String source;
  final DateTime date;
  final String note;

  _IncomeEntryResult({
    required this.amount,
    required this.source,
    required this.date,
    required this.note,
  });
}