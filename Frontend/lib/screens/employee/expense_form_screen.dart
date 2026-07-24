import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/dto_models.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_text_field.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense; // null for Create, non-null for Edit

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  DateTime _expenseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    if (expenseProvider.categories.isEmpty) {
      expenseProvider.fetchCategories();
    }

    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _expenseDate = widget.expense!.expenseDate;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null && widget.expense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expense category'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final description = _descriptionController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final categoryId = _selectedCategory?.categoryId ?? widget.expense!.categoryId;

    bool success = false;
    if (widget.expense == null) {
      final dto = CreateExpenseDTO(
        categoryId: categoryId,
        description: description,
        amount: amount,
        expenseDate: _expenseDate,
      );
      success = await expenseProvider.createExpense(dto);
    } else {
      final dto = UpdateExpenseDTO(
        categoryId: categoryId,
        description: description,
        amount: amount,
        expenseDate: _expenseDate,
      );
      success = await expenseProvider.updateExpense(widget.expense!.expenseId, dto);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.expense == null
              ? 'Expense claim created successfully!'
              : 'Expense claim updated successfully!'),
          backgroundColor: Colors.indigo,
        ),
      );
    } else if (expenseProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(expenseProvider.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final isEditing = widget.expense != null;
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense Claim' : 'New Expense Claim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                hint: Text(
                  isEditing ? widget.expense!.categoryName : 'Select Category',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                items: expenseProvider.categories.map((cat) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: cat,
                    child: Text(cat.categoryName),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: Colors.indigoAccent),
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _amountController,
                label: 'Amount (\$)',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: '0.00',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter expense amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              const Text(
                'Expense Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.indigoAccent),
                          const SizedBox(width: 12),
                          Text(
                            dateFormatter.format(_expenseDate),
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description / Purpose',
                prefixIcon: Icons.notes,
                maxLines: 3,
                hintText: 'Enter itemized details or business reason...',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter expense description';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: expenseProvider.isLoading ? null : _submit,
                child: expenseProvider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Submit Expense Claim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
