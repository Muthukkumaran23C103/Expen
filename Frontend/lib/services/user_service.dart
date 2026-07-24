import '../models/dto_models.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  Future<UserModel> createUser(CreateUserDTO dto) async {
    final response = await ApiService.post('User/CreateUser', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getPendingSignups() async {
    final response = await ApiService.get('User/GetPendingSignups');
    if (response is List) {
      return response.map((item) => UserModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<UserModel> approveSignup(ApproveSignupDTO dto) async {
    final response = await ApiService.post('User/ApproveSignup', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<UserModel> rejectSignup(RejectSignupDTO dto) async {
    final response = await ApiService.post('User/RejectSignup', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<UserModel> assignManager(AssignManagerDTO dto) async {
    final response = await ApiService.put('User/AssignManager', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<UserModel> changeRole(ChangeRoleDTO dto) async {
    final response = await ApiService.put('User/ChangeRole', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await ApiService.get('User/GetAllUsers');
    if (response is List) {
      return response.map((item) => UserModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<UserModel>> getManagers() async {
    final response = await ApiService.get('User/GetManagers');
    if (response is List) {
      return response.map((item) => UserModel.fromJson(item)).toList();
    }
    return [];
  }
}
