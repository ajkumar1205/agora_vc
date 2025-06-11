import 'package:agora_vc/src/data/remote/providers/auth_provider_impl.dart';
import 'package:agora_vc/src/data/remote/providers/user_provider_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/auth_repository_impl.dart';
import 'package:agora_vc/src/data/remote/repositories/user_repository_impl.dart';
import 'package:agora_vc/src/data/local/providers/local_user_provider.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';
import 'package:agora_vc/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/user/user_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/video_call/video_call_cubit.dart';
import 'package:agora_vc/src/core/services/call_signaling_service.dart';
import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:get_it/get_it.dart';

final _get = GetIt.I;

abstract class DependencyManager {
  static void injectDependencies() {
    _injectRouter();
    _injectAuth();
    _injectUser();
    _injectLocalUser();
    _injectVideoCall();
    _injectCubits();
  }

  static void _injectRouter() {
    _get.registerSingleton<AppRouter>(AppRouter());
  }

  static void _injectAuth() {
    _get.registerSingleton<AuthProvider>(AuthProviderImpl());
    _get.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(provider: _get<AuthProvider>()),
    );
  }

  static void _injectUser() {
    _get.registerSingleton<UserProvider>(UserProviderImpl());
    _get.registerSingleton<UserRepository>(
      UserRepositoryImpl(provider: _get<UserProvider>()),
    );
  }

  static void _injectLocalUser() {
    _get.registerSingleton<LocalUserProvider>(LocalUserProvider());
    _get.registerSingleton<LocalUserRepository>(
      LocalUserRepository(provider: _get<LocalUserProvider>()),
    );
  }

  static void _injectVideoCall() {
    _get.registerSingleton<CallSignalingService>(CallSignalingService());
  }

  static void _injectCubits() {
    _get.registerFactory<AuthCubit>(
      () => AuthCubit(
        authRepository: _get<AuthRepository>(),
        localUserRepository: _get<LocalUserRepository>(),
      ),
    );
    _get.registerFactory<UserCubit>(
      () => UserCubit(
        userRepository: _get<UserRepository>(),
        localUserRepository: _get<LocalUserRepository>(),
      ),
    );
    _get.registerFactory<VideoCallCubit>(
      () => VideoCallCubit(signalingService: _get<CallSignalingService>()),
    );
  }
}
