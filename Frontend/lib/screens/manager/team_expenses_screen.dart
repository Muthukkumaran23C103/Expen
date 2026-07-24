import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/stat_card.dart';

class TeamExpensesScreen extends StatefulWidget {
  const TeamExpensesScreen({super.key});

  @override
  State<TeamExpensesScreen> createState() => _TeamExpensesScreenState();
}

class _TeamExpensesScreenState extends State<TeamExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchTeamExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    List<Expense> filteredExpenses = provider.teamExpenses;
    if (provider.selectedStatusFilter != null) {
      filteredExpenses = filteredExpenses
          .where((e) => e.status == provider.selectedStatusFilter)
          .toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchTeamExpenses(statusFilter: provider.selectedStatusFilter),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Team Total',
                      value: currencyFormatter.format(provider.teamTotalAmount),
                      icon: Icons.groups,
                      color: Colors.indigoAccent,
                      subtitle: '${provider.teamExpenses.length} total items',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Pending Queue',
                      value: '${provider.pendingApprovalsCount}',
                      icon: Icons.hourglass_top,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Team Claims'),
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
                          'No team expenses found.',
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
                    return ExpenseCard(
                      expense: filteredExpenses[index],
                      showUser: true,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
