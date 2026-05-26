import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/table_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _initializedUserId;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTables();
    });
  }

  Future<void> _initializeTables([String? userId]) async {
    if (_isInitializing) return; // Prevent concurrent initialization

    final resolvedUserId =
        userId ?? context.read<AuthProvider>().currentUser?.uid;
    if (resolvedUserId == null) {
      return;
    }

    if (_initializedUserId == resolvedUserId) {
      return;
    }

    _isInitializing = true;
    try {
      final tableProvider = context.read<TableProvider>();
      final userProvider = context.read<UserProvider>();
      await tableProvider.initializeUser(resolvedUserId);
      await userProvider.loadUserProfile();
      if (mounted) {
        _initializedUserId = resolvedUserId;
      }
    } catch (e) {
      debugPrint('Error initializing tables: $e');
    } finally {
      _isInitializing = false;
    }
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
        title: const Text('Hotel Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<TableProvider>(
        builder: (context, tableProvider, _) {
          if (tableProvider.isLoading) {
            return const LoadingIndicator();
          }

          return Column(
            children: [
              // Grand total section
              _buildGrandTotalSection(tableProvider),

              // Tab bar for Open/Closed tables
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Open Tables (${tableProvider.openTables.length})'),
                  Tab(
                    text:
                        'Closed Tables (${tableProvider.closedTables.length})',
                  ),
                ],
              ),

              // Tables list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTablesList(tableProvider, tableProvider.openTables),
                    _buildTablesList(tableProvider, tableProvider.closedTables),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTableDialog,
        tooltip: 'Add Table',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrandTotalSection(TableProvider tableProvider) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grand Total (Open Tables)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tableProvider.grandTotal.toCurrency(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesList(
    TableProvider tableProvider,
    List<TableModel> tables,
  ) {
    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tables available',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return _buildTableCard(table, tableProvider);
      },
    );
  }

  Widget _buildTableCard(TableModel table, TableProvider tableProvider) {
    final statusColor = table.isOpen ? Colors.green : Colors.grey;
    final statusText = table.isOpen ? 'Open' : 'Closed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'T${table.tableNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ),
        title: Text('Table ${table.tableNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders: ${table.orders.length} | Status: $statusText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Subtotal: ${table.subtotal.toCurrency()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tax: ${table.taxAmount.toCurrency()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              table.totalAmount.toCurrency(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: table.isOpen ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 24,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => _showTableOptionsMenu(table, tableProvider),
                child: const Icon(Icons.more_vert, size: 16),
              ),
            ),
          ],
        ),
        onTap: () => _showTableDetailsDialog(table),
      ),
    );
  }

  void _showTableDetailsDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.tableNumber} Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${table.isOpen ? "Open" : "Closed"}'),
              const SizedBox(height: 12),
              Text(
                'Orders (${table.orders.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Divider(),
              if (table.orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No orders yet',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...table.orders.map((order) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.itemName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Qty: ${order.quantity} × ${order.itemPrice.toCurrency()}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          order.totalPrice.toCurrency(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          table.subtotal.toCurrency(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tax (5%):',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          table.taxAmount.toCurrency(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          table.totalAmount.toCurrency(),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (table.isOpen)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddOrderDialog(table);
              },
              child: const Text('Add Order'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddTableDialog() {
    final tableNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Table'),
        content: TextField(
          controller: tableNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter table number',
            labelText: 'Table Number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final tableNumber = int.tryParse(tableNumberController.text);
              if (tableNumber == null || tableNumber <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid table number'),
                  ),
                );
                return;
              }

              final userId = context.read<AuthProvider>().currentUser?.uid;
              if (userId == null) return;

              // Capture context and navigator before async operation
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await context.read<TableProvider>().createTable(
                  userId,
                  tableNumber,
                );
                if (!mounted) return;

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Table created successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddOrderDialog(TableModel table) {
    final itemNameController = TextEditingController();
    final itemPriceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Coffee',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: itemPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: '1',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g., Extra sugar',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final itemName = itemNameController.text.trim();
              final itemPrice = double.tryParse(itemPriceController.text);
              final quantity = int.tryParse(quantityController.text);
              final notes = notesController.text.trim();

              if (itemName.isEmpty ||
                  itemPrice == null ||
                  quantity == null ||
                  quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await context.read<TableProvider>().addOrder(
                  tableId: table.id,
                  itemName: itemName,
                  itemPrice: itemPrice,
                  quantity: quantity,
                  notes: notes.isEmpty ? null : notes,
                );

                if (!mounted) return;

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Order added successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add Order'),
          ),
        ],
      ),
    );
  }

  void _showTableOptionsMenu(TableModel table, TableProvider tableProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _showTableDetailsDialog(table);
            },
          ),
          if (table.isOpen)
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Close Table'),
              onTap: () async {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await tableProvider.closeTable(table.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Table closed successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Reopen Table'),
              onTap: () async {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await tableProvider.reopenTable(table.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Table reopened successfully'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Table',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Table?'),
                  content: Text(
                    'Are you sure you want to delete Table ${table.tableNumber}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await tableProvider.deleteTable(table.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Table deleted successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
