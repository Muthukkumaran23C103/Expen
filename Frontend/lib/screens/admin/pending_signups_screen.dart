import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/status_badge.dart';

class PendingSignupsScreen extends StatefulWidget {
  const PendingSignupsScreen({super.key});

  @override
  State<PendingSignupsScreen> createState() => _PendingSignupsScreenState();
}

class _PendingSignupsScreenState extends State<PendingSignupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserManagementProvider>(context, listen: false);
      provider.fetchPendingSignups();
      provider.fetchManagers();
    });
  }

  void _showApproveDialog(UserModel user) {
    UserRole selectedRole = user.userRole;
    UserModel? selectedManager;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final userMgmt = Provider.of<UserManagementProvider>(context);

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.person_add_alt_1, color: Colors.teal),
                const SizedBox(width: 10),
                Expanded(child: Text('Approve Signup: ${user.fullName}')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user.email}', style: TextStyle(color: Colors.grey.shade400)),
                  const SizedBox(height: 16),
                  const Text('Confirmed Role:', style: TextStyle(fontWeight: FontWeight.bold)),
                  RadioListTile<UserRole>(
                    title: const Text('Employee'),
                    value: UserRole.employee,
                    groupValue: selectedRole,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  RadioListTile<UserRole>(
                    title: const Text('Manager'),
                    value: UserRole.manager,
                    groupValue: selectedRole,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedRole == UserRole.employee || userMgmt.managers.isNotEmpty) ...[
                    const Text('Assign Manager:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<UserModel?>(
                      value: selectedManager,
                      hint: const Text('Select Manager'),
                      items: [
                        const DropdownMenuItem<UserModel?>(
                          value: null,
                          child: Text('None / Unassigned'),
                        ),
                        ...userMgmt.managers.map((m) {
                          return DropdownMenuItem<UserModel?>(
                            value: m,
                            child: Text(m.fullName),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setDialogState(() => selectedManager = val);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.supervisor_account),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () async {
                  if (selectedRole == UserRole.employee && selectedManager == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Employees must be assigned a manager.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  final success = await userMgmt.approveSignup(
                    user.userId,
                    selectedRole,
                    selectedManager?.userId,
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Approved ${user.fullName}\'s signup.'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
                child: const Text('Confirm Approval'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmReject(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Signup Request?'),
        content: Text('Are you sure you want to reject ${user.fullName}\'s signup request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final userMgmt = Provider.of<UserManagementProvider>(context, listen: false);
              final success = await userMgmt.rejectSignup(user.userId);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rejected ${user.fullName}\'s signup.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchPendingSignups();
          await provider.fetchManagers();
        },
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
                    'Pending User Signups',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text('${provider.pendingSignups.length} Requests'),
                    backgroundColor: Colors.amber.withOpacity(0.2),
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
              else if (provider.pendingSignups.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_add_disabled, size: 56, color: Colors.grey.shade600),
                        const SizedBox(height: 14),
                        const Text(
                          'No Pending Signups',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'All signup requests have been reviewed.',
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
                  itemCount: provider.pendingSignups.length,
                  itemBuilder: (ctx, index) {
                    final user = provider.pendingSignups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                    ),
                                  ],
                                ),
                                StatusBadge(status: user.approvalStatus),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text('Requested Role: ${user.userRole.name.toUpperCase()}'),
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                  ),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Reject'),
                                  onPressed: () => _confirmReject(user),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Approve Signup'),
                                  onPressed: () => _showApproveDialog(user),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
