import 'package:agora_vc/src/data/remote/providers/auth_provider_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/base_repository.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository<AuthProviderImpl>
    implements AuthRepository {
  AuthRepositoryImpl({required super.provider});

  @override
  Future createUser() {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future login() {
    // TODO: implement login
    throw UnimplementedError();
  }
}
