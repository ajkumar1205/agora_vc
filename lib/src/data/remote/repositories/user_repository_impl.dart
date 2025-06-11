import 'package:agora_vc/src/data/base_repository.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends BaseRepository<UserProvider>
    implements UserRepository {
  UserRepositoryImpl({required super.provider});

  @override
  Future<BaseResponseModel<List<UserModel>>> getUsers() async {
    return await get(provider.getUsers());
  }
}
