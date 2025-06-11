import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

abstract class AuthRepository {
  Future<BaseResponseModel<UserModel>> createUser({
    required String name,
    required String email,
    required String password,
  });
  Future<BaseResponseModel<UserModel>> login({
    required String email,
    required String password,
  });
}