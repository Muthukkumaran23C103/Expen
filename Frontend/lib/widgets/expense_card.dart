import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'status_badge.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final bool showUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReview;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.showUser = false,
    this.onEdit,
    this.onDelete,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(expense.categoryName),
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (showUser)
                              Text(
                                'by ${expense.userName}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormatter.format(expense.amount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              expense.description,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      dateFormatter.format(expense.expenseDate),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
                StatusBadge(status: expense.status),
              ],
            ),
            if (expense.managerComment != null && expense.managerComment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  'Manager Comment: "${expense.managerComment}"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (expense.status == ExpenseStatus.pending && (onEdit != null || onDelete != null || onReview != null)) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReview != null)
                    ElevatedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.rate_review, size: 16),
                      label: const Text('Review Claim'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  if (onEdit != null)
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 8),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('travel') || cat.contains('flight') || cat.contains('taxi')) return Icons.flight_takeoff;
    if (cat.contains('food') || cat.contains('meal') || cat.contains('dining')) return Icons.restaurant;
    if (cat.contains('hotel') || cat.contains('stay') || cat.contains('lodging')) return Icons.hotel;
    if (cat.contains('tech') || cat.contains('software') || cat.contains('hardware')) return Icons.devices;
    if (cat.contains('office') || cat.contains('supplies')) return Icons.card_membership;
    return Icons.receipt_long;
  }
}
