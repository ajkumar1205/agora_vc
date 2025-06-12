import 'package:agora_vc/di.dart';
import 'package:agora_vc/firebase_options.dart';
import 'package:agora_vc/hive_registrar.g.dart';
import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:agora_vc/src/core/services/notification_service.dart';
import 'package:agora_vc/src/core/services/navigation_service.dart';
import 'package:agora_vc/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/user/user_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/video_call/video_call_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().initialize();
  await Hive.initFlutter();
  Hive.registerAdapters();
  await DependencyManager.openHiveBoxes();
  DependencyManager.injectDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(navigatorKey: NavigationService.navigatorKey);
    NavigationService().initialize(appRouter);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => GetIt.I<AuthCubit>()),
        BlocProvider<UserCubit>(create: (context) => GetIt.I<UserCubit>()),
        BlocProvider<VideoCallCubit>(
          create: (context) => GetIt.I<VideoCallCubit>(),
        ),
        BlocProvider(create: (context) => GetIt.I<ProfileCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'One-to-One Video Call',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: appRouter.config(),
      ),
    );
  }
}
