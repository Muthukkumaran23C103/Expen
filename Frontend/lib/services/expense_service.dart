import '../models/dto_models.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'api_service.dart';

class ExpenseService {
  Future<Expense> createExpense(CreateExpenseDTO dto) async {
    final response = await ApiService.post('Expense/CreateExpense', dto.toJson());
    return Expense.fromJson(response);
  }

  Future<List<Expense>> getMyExpenses({ExpenseStatus? status}) async {
    String endpoint = 'Expense/GetMyExpenses';
    if (status != null) {
      endpoint += '?status=${status.index}';
    }
    final response = await ApiService.get(endpoint);
    if (response is List) {
      return response.map((item) => Expense.fromJson(item)).toList();
    }
    return [];
  }

  Future<Expense> updateExpense(String id, UpdateExpenseDTO dto) async {
    final response = await ApiService.put('Expense/UpdateExpense/$id', dto.toJson());
    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(String id) async {
    await ApiService.delete('Expense/DeleteExpense/$id');
  }

  Future<List<Expense>> getPendingApprovals() async {
    final response = await ApiService.get('Expense/GetPendingApprovals');
    if (response is List) {
      return response.map((item) => Expense.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<Expense>> getTeamExpenses({ExpenseStatus? status}) async {
    String endpoint = 'Expense/GetTeamExpenses';
    if (status != null) {
      endpoint += '?status=${status.index}';
    }
    final response = await ApiService.get(endpoint);
    if (response is List) {
      return response.map((item) => Expense.fromJson(item)).toList();
    }
    return [];
  }

  Future<Expense> reviewExpense(ReviewExpenseDTO dto) async {
    final response = await ApiService.post('Expense/ReviewExpense', dto.toJson());
    return Expense.fromJson(response);
  }

  Future<List<Expense>> getAllExpenses({ExpenseStatus? status}) async {
    String endpoint = 'Expense/GetAllExpenses';
    if (status != null) {
      endpoint += '?status=${status.index}';
    }
    final response = await ApiService.get(endpoint);
    if (response is List) {
      return response.map((item) => Expense.fromJson(item)).toList();
    }
    return [];
  }

  Future<Expense> getExpenseById(String id) async {
    final response = await ApiService.get('Expense/GetExpenseById/$id');
    return Expense.fromJson(response);
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final response = await ApiService.get('Expense/GetCategories');
    if (response is List) {
      return response.map((item) => ExpenseCategory.fromJson(item)).toList();
    }
    return [];
  }
}
