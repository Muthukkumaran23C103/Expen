import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/user_management_provider.dart';
import 'admin/company_expenses_screen.dart';
import 'admin/pending_signups_screen.dart';
import 'admin/user_management_screen.dart';
import 'employee/my_expenses_screen.dart';
import 'manager/pending_approvals_screen.dart';
import 'manager/team_expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final userMgmtProvider = Provider.of<UserManagementProvider>(context);

    final role = authProvider.role.toLowerCase();

    List<Widget> screens = [];
    List<NavigationDestination> destinations = [];

    if (role == 'admin') {
      screens = const [
        CompanyExpensesScreen(),
        PendingSignupsScreen(),
        UserManagementScreen(),
      ];
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: 'Company Audit',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: userMgmtProvider.pendingSignupsCount > 0,
            label: Text('${userMgmtProvider.pendingSignupsCount}'),
            child: const Icon(Icons.person_add_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: userMgmtProvider.pendingSignupsCount > 0,
            label: Text('${userMgmtProvider.pendingSignupsCount}'),
            child: const Icon(Icons.person_add),
          ),
          label: 'Pending Signups',
        ),
        const NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Users Directory',
        ),
      ];
    } else if (role == 'manager') {
      screens = const [
        MyExpensesScreen(),
        PendingApprovalsScreen(),
        TeamExpensesScreen(),
      ];
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'My Expenses',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: expenseProvider.pendingApprovalsCount > 0,
            label: Text('${expenseProvider.pendingApprovalsCount}'),
            child: const Icon(Icons.rate_review_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: expenseProvider.pendingApprovalsCount > 0,
            label: Text('${expenseProvider.pendingApprovalsCount}'),
            child: const Icon(Icons.rate_review),
          ),
          label: 'Team Approvals',
        ),
        const NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Team Audit',
        ),
      ];
    } else {
      // Employee
      screens = const [
        MyExpensesScreen(),
      ];
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'My Expenses',
        ),
      ];
    }

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.indigoAccent),
            const SizedBox(width: 10),
            const Text(
              'ExpenSR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authProvider.role.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Navigator.pop(ctx);
                        authProvider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: destinations.length > 1
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: destinations,
            )
          : null,
    );
  }
}
