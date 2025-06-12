import 'dart:developer';

import 'package:agora_vc/src/core/utils/app_paths.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/presentation/screens/call_logs_screen.dart';
import 'package:agora_vc/src/presentation/screens/home_screen.dart';
import 'package:agora_vc/src/presentation/screens/login_screen.dart';
import 'package:agora_vc/src/presentation/screens/sign_up_screen.dart';
import 'package:agora_vc/src/presentation/screens/video_call_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'app_router.gr.dart';

final router = AppRouter();

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: LoginRoute.page,
      path: AppPaths.login,
      initial: true,
      guards: [AuthGuard(localUserRepository: GetIt.I<LocalUserRepository>())],
    ),
    AutoRoute(page: SignUpRoute.page, path: AppPaths.signUp),
    AutoRoute(page: HomeRoute.page, path: AppPaths.home),
    AutoRoute(page: CallLogsRoute.page, path: AppPaths.callLogs),
    AutoRoute(page: VideoCallRoute.page, path: AppPaths.videoCall),
  ];
}

class AuthGuard extends AutoRouteGuard {
  final LocalUserRepository localUserRepository;
  AuthGuard({required this.localUserRepository});
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    log('AuthGuard: Checking authentication status');
    final user = await localUserRepository.getCurrentUser();
    log(user.toString());
    if (user is Success<UserModel?> && user.data != null) {
      log('AuthGuard: User is authenticated');
      log("User is ${user.data!.toJson()}");
      router.popUntil((route) => route.isFirst);
      router.replace(const HomeRoute());
    } else {
      log('AuthGuard: User is not authenticated');
      resolver.next(true);
    }
  }
}
