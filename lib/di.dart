

import 'package:agora_vc/src/data/remote/providers/auth_provider_impl.dart';
import 'package:agora_vc/src/data/remote/providers/user_provider_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/auth_repository_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/user_repository_impl.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

final _get = GetIt.I;

abstract class DependencyManager {
  static void injectDependencies() {
    _injectAuth();
    _injectUser();
  }

  static void _injectAuth(){
    _get.registerSingleton<AuthProvider>(AuthProviderImpl());
    _get.registerSingleton<AuthRepository>(AuthRepositoryImpl(provider: _get<AuthProvider>()));
  }

  static void _injectUser(){
    _get.registerSingleton<UserProvider>(UserProviderImpl());
    _get.registerSingleton<UserRepository>(UserRepositoryImpl(provider: _get<UserProvider>()));
  }
}