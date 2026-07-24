import '../models/auth_response.dart';
import '../models/dto_models.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  Future<UserModel> signUpUser(SignUpUserDTO dto) async {
    final response = await ApiService.post('Auth/SignUpUser', dto.toJson());
    return UserModel.fromJson(response);
  }

  Future<AuthResponse> loginUser(LoginUserDTO dto) async {
    final response = await ApiService.post('Auth/LoginUser', dto.toJson());
    final auth = AuthResponse.fromJson(response);
    ApiService.setAuthToken(auth.token);
    return auth;
  }

  Future<AuthResponse> loginAdmin(LoginUserDTO dto) async {
    final response = await ApiService.post('Auth/LoginAdmin', dto.toJson());
    final auth = AuthResponse.fromJson(response);
    ApiService.setAuthToken(auth.token);
    return auth;
  }
}
