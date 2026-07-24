import 'package:flutter/foundation.dart';
import '../models/dto_models.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  List<UserModel> _pendingSignups = [];
  List<UserModel> _managers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  List<UserModel> get pendingSignups => _pendingSignups;
  List<UserModel> get managers => _managers;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingSignupsCount => _pendingSignups.length;

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingSignups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingSignups = await _userService.getPendingSignups();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchManagers() async {
    try {
      _managers = await _userService.getManagers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching managers: $e');
    }
  }

  Future<bool> createUser(CreateUserDTO dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _userService.createUser(dto);
      _users.insert(0, newUser);
      if (newUser.userRole == UserRole.manager) {
        _managers.add(newUser);
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

  Future<bool> approveSignup(String userId, UserRole role, String? managerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = ApproveSignupDTO(userId: userId, userRole: role, managerId: managerId);
      final approved = await _userService.approveSignup(dto);
      _pendingSignups.removeWhere((u) => u.userId == userId);
      _users.insert(0, approved);
      if (approved.userRole == UserRole.manager) {
        _managers.add(approved);
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

  Future<bool> rejectSignup(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = RejectSignupDTO(userId: userId);
      await _userService.rejectSignup(dto);
      _pendingSignups.removeWhere((u) => u.userId == userId);
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

  Future<bool> assignManager(String userId, String? managerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = AssignManagerDTO(userId: userId, managerId: managerId);
      final updated = await _userService.assignManager(dto);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) {
        _users[index] = updated;
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

  Future<bool> changeRole(String userId, UserRole newRole) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = ChangeRoleDTO(userId: userId, newRole: newRole);
      final updated = await _userService.changeRole(dto);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) {
        _users[index] = updated;
      }
      await fetchManagers(); // refresh manager list
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
}
