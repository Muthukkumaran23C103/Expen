import 'package:flutter/foundation.dart';
import '../models/dto_models.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<Expense> _myExpenses = [];
  List<Expense> _pendingApprovals = [];
  List<Expense> _teamExpenses = [];
  List<Expense> _companyExpenses = [];
  List<ExpenseCategory> _categories = [];

  bool _isLoading = false;
  String? _errorMessage;

  ExpenseStatus? _selectedStatusFilter;

  List<Expense> get myExpenses => _myExpenses;
  List<Expense> get pendingApprovals => _pendingApprovals;
  List<Expense> get teamExpenses => _teamExpenses;
  List<Expense> get companyExpenses => _companyExpenses;
  List<ExpenseCategory> get categories => _categories;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ExpenseStatus? get selectedStatusFilter => _selectedStatusFilter;

  // Metrics
  double get myTotalAmount =>
      _myExpenses.fold(0.0, (sum, item) => sum + item.amount);
  double get myApprovedAmount => _myExpenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold(0.0, (sum, item) => sum + item.amount);
  int get myPendingCount =>
      _myExpenses.where((e) => e.status == ExpenseStatus.pending).length;

  double get teamTotalAmount =>
      _teamExpenses.fold(0.0, (sum, item) => sum + item.amount);
  int get pendingApprovalsCount => _pendingApprovals.length;

  void setStatusFilter(ExpenseStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _expenseService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchMyExpenses({ExpenseStatus? statusFilter}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myExpenses = await _expenseService.getMyExpenses(status: statusFilter);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense(CreateExpenseDTO dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newExpense = await _expenseService.createExpense(dto);
      _myExpenses.insert(0, newExpense);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(String id, UpdateExpenseDTO dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _expenseService.updateExpense(id, dto);
      final index = _myExpenses.indexWhere((e) => e.expenseId == id);
      if (index != -1) {
        _myExpenses[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _expenseService.deleteExpense(id);
      _myExpenses.removeWhere((e) => e.expenseId == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Manager functions
  Future<void> fetchPendingApprovals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingApprovals = await _expenseService.getPendingApprovals();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamExpenses({ExpenseStatus? statusFilter}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teamExpenses =
          await _expenseService.getTeamExpenses(status: statusFilter);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewExpense(
      String expenseId, bool approve, String? comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = ReviewExpenseDTO(
          expenseId: expenseId, approve: approve, comment: comment);
      final updated = await _expenseService.reviewExpense(dto);

      _pendingApprovals.removeWhere((e) => e.expenseId == expenseId);

      final index = _teamExpenses.indexWhere((e) => e.expenseId == expenseId);
      if (index != -1) {
        _teamExpenses[index] = updated;
      } else {
        _teamExpenses.insert(0, updated);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin functions
  Future<void> fetchCompanyExpenses({ExpenseStatus? statusFilter}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companyExpenses =
          await _expenseService.getAllExpenses(status: statusFilter);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
