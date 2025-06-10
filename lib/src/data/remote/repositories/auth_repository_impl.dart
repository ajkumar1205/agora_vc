import 'package:agora_vc/src/data/remote/repositories/base_repository.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository<AuthProvider>
    implements AuthRepository {
  AuthRepositoryImpl({required super.provider});

  @override
  Future createUser() {
    // TODO: implement createUser
    provider.createUser();
    throw UnimplementedError();
  }

  @override
  Future login() {
    // TODO: implement login
    provider.login();
    throw UnimplementedError();
  }
}
