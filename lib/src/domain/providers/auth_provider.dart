

abstract class AuthProvider {
  Future createUser({
    required String name,
    required String email,
    required String password,
  });

  Future login({
    required String email,
    required String password,
  });
}