import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/expense_card.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchPendingApprovals();
    });
  }

  void _showReviewDialog(Expense expense) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.rate_review, color: Colors.indigoAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Review Claim #${expense.expenseId.substring(0, 8)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submitted by: ${expense.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
            Text('Category: ${expense.categoryName}'),
            const SizedBox(height: 12),
            Text('Description: "${expense.description}"', style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Manager Comment',
                hintText: 'Add comment (Required if rejecting)...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            onPressed: () async {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A comment is required when rejecting a claim.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              final success = await provider.reviewExpense(expense.expenseId, false, commentController.text.trim());
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Claim rejected.'), backgroundColor: Colors.redAccent),
                );
              }
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              final success = await provider.reviewExpense(
                expense.expenseId,
                true,
                commentController.text.trim().isEmpty ? null : commentController.text.trim(),
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Claim approved successfully!'), backgroundColor: AppTheme.emerald),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchPendingApprovals(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Team Approval Queue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text('${provider.pendingApprovals.length} Pending'),
                    backgroundColor: Colors.amber.withValues(alpha: 0.2),
                    labelStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.pendingApprovals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 56, color: AppTheme.emerald),
                        const SizedBox(height: 14),
                        const Text(
                          'Queue Clean!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No pending expense claims from your team members.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.pendingApprovals.length,
                  itemBuilder: (ctx, index) {
                    final item = provider.pendingApprovals[index];
                    return ExpenseCard(
                      expense: item,
                      showUser: true,
                      onReview: () => _showReviewDialog(item),
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
