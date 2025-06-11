import 'package:agora_vc/src/data/base_repository.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository<AuthProvider>
    implements AuthRepository {
  AuthRepositoryImpl({required super.provider});

  @override
  Future<BaseResponseModel<UserModel>> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return await get(
      provider.createUser(name: name, email: email, password: password),
    );
  }

  @override
  Future<BaseResponseModel<UserModel>> login({
    required String email,
    required String password,
  }) async {
    return await get(provider.login(email: email, password: password));
  }
}
