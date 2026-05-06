import '../../data/models/auth_token_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthTokenModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String investorProfile,
  });
}
