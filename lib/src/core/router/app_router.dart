import 'package:agora_vc/src/core/utils/app_paths.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/presentation/screens/call_logs_screen.dart';
import 'package:agora_vc/src/presentation/screens/home_screen.dart';
import 'package:agora_vc/src/presentation/screens/login_screen.dart';
import 'package:agora_vc/src/presentation/screens/sign_up_screen.dart';
import 'package:agora_vc/src/presentation/screens/user_indentity_screen.dart';
import 'package:agora_vc/src/presentation/screens/user_selection_screen.dart';
import 'package:agora_vc/src/presentation/screens/video_call_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

final router = AppRouter();

@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: AppPaths.login, initial: true),
    AutoRoute(page: SignUpRoute.page, path: AppPaths.signUp),
    AutoRoute(page: HomeRoute.page, path: AppPaths.home),
    AutoRoute(page: CallLogsRoute.page, path: AppPaths.callLogs),
    AutoRoute(page: UserIdentityRoute.page, path: AppPaths.userIdentity),
    AutoRoute(page: UserSelectionRoute.page, path: AppPaths.userSelection),
    AutoRoute(page: VideoCallRoute.page, path: AppPaths.videoCall),
  ];
}
