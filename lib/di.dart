import 'package:agora_vc/src/data/local/providers/local_user_provider.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';
import 'package:agora_vc/src/data/remote/providers/auth_provider_impl.dart';
import 'package:agora_vc/src/data/remote/providers/user_provider_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/auth_repository_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/user_repository_impl.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';
import 'package:agora_vc/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/user/user_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final _get = GetIt.I;

abstract class DependencyManager {
  static void injectDependencies() {
    _injectAuth();
    _injectUser();
  }

  static void _injectAuth() {
    _get.registerSingleton<AuthProvider>(AuthProviderImpl());
    _get.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(provider: _get<AuthProvider>()),
    );
    _get.registerSingleton<LocalUserProvider>(LocalUserProvider());
    _get.registerSingleton<LocalUserRepository>(LocalUserRepository(provider: _get<LocalUserProvider>()));
    _get.registerFactory<AuthCubit>(
      () => AuthCubit(authRepository: _get<AuthRepository>(), localUserRepository: _get<LocalUserRepository>()),
    );
  }

  static void _injectUser() {
    _get.registerSingleton<UserProvider>(UserProviderImpl());
    _get.registerSingleton<UserRepository>(
      UserRepositoryImpl(provider: _get<UserProvider>()),
    );
    _get.registerFactory<UserCubit>(
      () => UserCubit(userRepository: _get<UserRepository>(), localUserRepository: _get<LocalUserRepository>()),
    );
  }

  static Future<void> openHiveBoxes () async {
    await Hive.openBox("config");
    await Hive.openBox<UserModel>("users");
  }
}
