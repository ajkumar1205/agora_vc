// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CallLogsScreen]
class CallLogsRoute extends PageRouteInfo<void> {
  const CallLogsRoute({List<PageRouteInfo>? children})
    : super(CallLogsRoute.name, initialChildren: children);

  static const String name = 'CallLogsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CallLogsScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
}

/// generated route for
/// [VideoCallScreen]
class VideoCallRoute extends PageRouteInfo<VideoCallRouteArgs> {
  VideoCallRoute({
    Key? key,
    required UserModel currentUser,
    required UserModel targetUser,
    required String channelName,
    required bool isCaller,
    List<PageRouteInfo>? children,
  }) : super(
         VideoCallRoute.name,
         args: VideoCallRouteArgs(
           key: key,
           currentUser: currentUser,
           targetUser: targetUser,
           channelName: channelName,
           isCaller: isCaller,
         ),
         initialChildren: children,
       );

  static const String name = 'VideoCallRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoCallRouteArgs>();
      return VideoCallScreen(
        key: args.key,
        currentUser: args.currentUser,
        targetUser: args.targetUser,
        channelName: args.channelName,
        isCaller: args.isCaller,
      );
    },
  );
}

class VideoCallRouteArgs {
  const VideoCallRouteArgs({
    this.key,
    required this.currentUser,
    required this.targetUser,
    required this.channelName,
    required this.isCaller,
  });

  final Key? key;

  final UserModel currentUser;

  final UserModel targetUser;

  final String channelName;

  final bool isCaller;

  @override
  String toString() {
    return 'VideoCallRouteArgs{key: $key, currentUser: $currentUser, targetUser: $targetUser, channelName: $channelName, isCaller: $isCaller}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoCallRouteArgs) return false;
    return key == other.key &&
        currentUser == other.currentUser &&
        targetUser == other.targetUser &&
        channelName == other.channelName &&
        isCaller == other.isCaller;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      currentUser.hashCode ^
      targetUser.hashCode ^
      channelName.hashCode ^
      isCaller.hashCode;
}
