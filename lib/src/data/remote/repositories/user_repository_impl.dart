import 'package:agora_vc/src/data/remote/providers/user_provider_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/base_repository.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends BaseRepository<UserProvider>
    implements UserRepository {
  UserRepositoryImpl({required super.provider});

  @override
  Future getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }
}
