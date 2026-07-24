import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/stat_card.dart';

class CompanyExpensesScreen extends StatefulWidget {
  const CompanyExpensesScreen({super.key});

  @override
  State<CompanyExpensesScreen> createState() => _CompanyExpensesScreenState();
}

class _CompanyExpensesScreenState extends State<CompanyExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchCompanyExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    List<Expense> filteredExpenses = provider.companyExpenses;
    if (provider.selectedStatusFilter != null) {
      filteredExpenses = filteredExpenses
          .where((e) => e.status == provider.selectedStatusFilter)
          .toList();
    }

    final totalCompanySpent = provider.companyExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final approvedCompanySpent = provider.companyExpenses
        .where((e) => e.status == ExpenseStatus.approved)
        .fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchCompanyExpenses(statusFilter: provider.selectedStatusFilter),
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
                      title: 'Company Total',
                      value: currencyFormatter.format(totalCompanySpent),
                      icon: Icons.account_balance,
                      color: Colors.indigoAccent,
                      subtitle: '${provider.companyExpenses.length} total claims',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Approved Spend',
                      value: currencyFormatter.format(approvedCompanySpent),
                      icon: Icons.verified,
                      color: Colors.teal,
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
                      label: const Text('All Company Claims'),
                      selected: provider.selectedStatusFilter == null,
                      onSelected: (_) => provider.setStatusFilter(null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.pending,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.pending),
                      selectedColor: Colors.amber.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.approved,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.approved),
                      selectedColor: Colors.teal.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Rejected'),
                      selected: provider.selectedStatusFilter == ExpenseStatus.rejected,
                      onSelected: (_) => provider.setStatusFilter(ExpenseStatus.rejected),
                      selectedColor: Colors.pink.withOpacity(0.3),
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
                          'No company expenses found.',
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
