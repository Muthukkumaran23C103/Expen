import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isAdminMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showBackendUrlDialog() async {
    final currentUrl = await ApiService.baseUrl;
    _urlController.text = currentUrl;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_remote, color: Colors.indigoAccent),
            SizedBox(width: 10),
            Text('Backend API Config'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the backend base API endpoint URL (e.g. for local development or remote server):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://localhost:7168/api',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Local HTTPS'),
                  onPressed: () => _urlController.text = 'https://localhost:7168/api',
                ),
                ActionChip(
                  label: const Text('Local HTTP'),
                  onPressed: () => _urlController.text = 'http://localhost:5000/api',
                ),
                ActionChip(
                  label: const Text('Android Emulator'),
                  onPressed: () => _urlController.text = 'http://10.0.2.2:5000/api',
                ),
              ],
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
              if (_urlController.text.trim().isNotEmpty) {
                final newUrl = _urlController.text.trim();
                await ApiService.setBaseUrl(newUrl);
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API Base URL updated to: $newUrl'),
                    backgroundColor: Colors.indigo,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = false;
    if (_isAdminMode) {
      success = await authProvider.loginAdmin(email, password);
    } else {
      success = await authProvider.loginUser(email, password);
    }

    if (!mounted) return;

    if (!success && authProvider.errorMessage != null) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            tooltip: 'Configure Backend URL',
            onPressed: _showBackendUrlDialog,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ExpenSR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Smart Enterprise Expense Claims Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Role Mode Toggle Switch
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isAdminMode = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isAdminMode
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Employee / Manager',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !_isAdminMode ? Colors.white : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isAdminMode = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isAdminMode
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Admin Portal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isAdminMode ? Colors.white : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter email address';
                      if (!val.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

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
                        : Text(_isAdminMode ? 'Sign In as Admin' : 'Sign In'),
                  ),

                  if (!_isAdminMode) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
