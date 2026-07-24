import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/stat_card.dart';
import 'expense_form_screen.dart';

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({super.key});

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      provider.fetchMyExpenses();
      provider.fetchCategories();
    });
  }

  void _confirmDelete(Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense Claim?'),
        content: Text('Are you sure you want to delete claim "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              final success = await provider.deleteExpense(expense.expenseId);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense claim deleted.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    List<Expense> filteredExpenses = provider.myExpenses;
    if (provider.selectedStatusFilter != null) {
      filteredExpenses = filteredExpenses
          .where((e) => e.status == provider.selectedStatusFilter)
          .toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMyExpenses(statusFilter: provider.selectedStatusFilter),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Claims',
                      value: currencyFormatter.format(provider.myTotalAmount),
                      icon: Icons.account_balance_wallet,
                      color: Colors.indigoAccent,
                      subtitle: '${provider.myExpenses.length} items',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Approved',
                      value: currencyFormatter.format(provider.myApprovedAmount),
                      icon: Icons.check_circle_outline,
                      color: AppTheme.emerald,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Pending',
                      value: '${provider.myPendingCount}',
                      icon: Icons.access_time,
                      color: Colors.amber,
                      subtitle: 'Awaiting review',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Claims'),
                      selected: provider.selectedStatusFilter == null,
                      onSelected: (_) => provider.setStatusFilter(null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.pending,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.pending),
                      selectedColor: Colors.amber.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.approved,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.approved),
                      selectedColor: AppTheme.emerald.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Rejected'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.rejected,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.rejected),
                      selectedColor: AppTheme.rose.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        Text(
                          'No expense claims found.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (ctx, index) {
                    final item = filteredExpenses[index];
                    return ExpenseCard(
                      expense: item,
                      onEdit: item.status == ExpenseStatus.pending
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpenseFormScreen(expense: item),
                                ),
                              );
                            }
                          : null,
                      onDelete: item.status == ExpenseStatus.pending
                          ? () => _confirmDelete(item)
                          : null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExpenseFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Claim'),
      ),
    );
  }
}
