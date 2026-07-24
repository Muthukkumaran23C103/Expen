import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dto_models.dart';
import '../../models/user_model.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/custom_text_field.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserManagementProvider>(context, listen: false);
      provider.fetchAllUsers();
      provider.fetchManagers();
    });
  }

  void _showCreateUserDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    UserRole selectedRole = UserRole.employee;
    UserModel? selectedManager;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final userMgmt = Provider.of<UserManagementProvider>(context);

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.person_add, color: Colors.indigoAccent),
                SizedBox(width: 10),
                Text('Create New User'),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: firstNameCtrl,
                      label: 'First Name',
                      prefixIcon: Icons.person,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: lastNameCtrl,
                      label: 'Last Name',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailCtrl,
                      label: 'Email Address',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: passwordCtrl,
                      label: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      validator: (val) => val == null || val.length < 6 ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 14),
                    const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Employee', style: TextStyle(fontSize: 13)),
                            value: UserRole.employee,
                            groupValue: selectedRole,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setDialogState(() => selectedRole = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Manager', style: TextStyle(fontSize: 13)),
                            value: UserRole.manager,
                            groupValue: selectedRole,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setDialogState(() => selectedRole = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Manager:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<UserModel?>(
                      value: selectedManager,
                      hint: const Text('Select Manager'),
                      items: [
                        const DropdownMenuItem<UserModel?>(
                          value: null,
                          child: Text('None / Direct Report to Admin'),
                        ),
                        ...userMgmt.managers.map((m) {
                          return DropdownMenuItem<UserModel?>(
                            value: m,
                            child: Text(m.fullName),
                          );
                        }),
                      ],
                      onChanged: (val) => setDialogState(() => selectedManager = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
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
                  final dto = CreateUserDTO(
                    firstName: firstNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim().isEmpty ? null : lastNameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                    userRole: selectedRole,
                    managerId: selectedManager?.userId,
                  );
                  final success = await userMgmt.createUser(dto);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User created successfully!'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  }
                },
                child: const Text('Create User'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignManagerDialog(UserModel user) {
    UserModel? selectedManager;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final userMgmt = Provider.of<UserManagementProvider>(context);

          return AlertDialog(
            title: Text('Assign Manager to ${user.fullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Manager: ${user.managerName ?? "None"}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserModel?>(
                  value: selectedManager,
                  hint: const Text('Select New Manager'),
                  items: [
                    const DropdownMenuItem<UserModel?>(
                      value: null,
                      child: Text('None (Clear Manager)'),
                    ),
                    ...userMgmt.managers
                        .where((m) => m.userId != user.userId)
                        .map((m) {
                      return DropdownMenuItem<UserModel?>(
                        value: m,
                        child: Text(m.fullName),
                      );
                    }),
                  ],
                  onChanged: (val) => setDialogState(() => selectedManager = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await userMgmt.assignManager(user.userId, selectedManager?.userId);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated manager assignment for ${user.fullName}.'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  }
                },
                child: const Text('Update Assignment'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeRoleDialog(UserModel user) {
    UserRole newRole = user.userRole;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final userMgmt = Provider.of<UserManagementProvider>(context);

          return AlertDialog(
            title: Text('Change Role for ${user.fullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Role: ${user.userRole.name.toUpperCase()}'),
                const SizedBox(height: 12),
                RadioListTile<UserRole>(
                  title: const Text('Employee'),
                  value: UserRole.employee,
                  groupValue: newRole,
                  onChanged: (val) => setDialogState(() => newRole = val!),
                ),
                RadioListTile<UserRole>(
                  title: const Text('Manager'),
                  value: UserRole.manager,
                  groupValue: newRole,
                  onChanged: (val) => setDialogState(() => newRole = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await userMgmt.changeRole(user.userId, newRole);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Changed role of ${user.fullName} to ${newRole.name.toUpperCase()}.'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  }
                },
                child: const Text('Save Role'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchAllUsers();
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
                    'Company Directory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateUserDialog,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add User'),
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
              else if (provider.users.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'No users registered yet.',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.users.length,
                  itemBuilder: (ctx, index) {
                    final user = provider.users[index];
                    final isManagerRole = user.userRole == UserRole.manager;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isManagerRole ? Colors.indigoAccent : Colors.lightBlueAccent,
                                  child: Icon(
                                    isManagerRole ? Icons.supervisor_account : Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
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
                                ),
                                Chip(
                                  label: Text(
                                    user.userRole.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: isManagerRole
                                      ? Colors.indigo.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                ),
                              ],
                            ),
                            if (user.managerName != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Reports to Manager: ${user.managerName}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.supervisor_account, size: 16),
                                  label: const Text('Assign Manager'),
                                  onPressed: () => _showAssignManagerDialog(user),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.badge, size: 16),
                                  label: const Text('Change Role'),
                                  onPressed: () => _showChangeRoleDialog(user),
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
