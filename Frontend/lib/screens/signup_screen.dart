import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dto_models.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.employee;

  @override
  void dispose() {
    _companyIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final dto = SignUpUserDTO(
      companyId: _companyIdController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      userRole: _selectedRole,
    );

    final success = await authProvider.signUp(dto);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Signup Request Sent'),
            ],
          ),
          content: const Text(
            'Your account request has been submitted successfully! An administrator will review and approve your account before you can log in.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Join your Organization',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your details below to request account access.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _companyIdController,
                    label: 'Company GUID',
                    prefixIcon: Icons.domain_outlined,
                    hintText: 'e.g. 11111111-1111-1111-1111-111111111111',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter Company ID';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          prefixIcon: Icons.person_outline,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter email address';
                      if (!val.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Role Requested',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Employee', style: TextStyle(fontSize: 14)),
                          value: UserRole.employee,
                          groupValue: _selectedRole,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Manager', style: TextStyle(fontSize: 14)),
                          value: UserRole.manager,
                          groupValue: _selectedRole,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Submit Registration'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
