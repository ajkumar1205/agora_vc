import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

abstract class UserRepository {
  Future<BaseResponseModel<List<UserModel>>> getUsers();
}