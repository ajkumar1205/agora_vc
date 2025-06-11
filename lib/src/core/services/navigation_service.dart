import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static late AppRouter appRouter;

  BuildContext? get context => navigatorKey.currentContext;
  StackRouter? get router => context?.router;

  void initialize(AppRouter router) {
    appRouter = router;
  }

  Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
    final action = data['action'] as String?;

    switch (action) {
      case 'accept_call':
        await _navigateToAcceptCall(data);
        break;
      case 'show_incoming_call':
        await _showIncomingCallDialog(data);
        break;
      default:
        await _navigateToHome();
        break;
    }
  }

  Future<void> _navigateToAcceptCall(Map<String, dynamic> data) async {
    final incomingCallData = data['incoming_call'] as Map<String, dynamic>?;
    if (incomingCallData == null || router == null) return;

    final caller = UserModel(
      uid: incomingCallData['caller']['uid'],
      name: incomingCallData['caller']['name'],
      email: incomingCallData['caller']['email'],
    );

    final channelName = incomingCallData['channelName'] as String;

    // Navigate to video call screen directly
    await router!.push(
      VideoCallRoute(
        currentUser: _getCurrentUser(),
        targetUser: caller,
        channelName: channelName,
        isCaller: false,
      ),
    );
  }

  Future<void> _showIncomingCallDialog(Map<String, dynamic> data) async {
    final incomingCallData = data['incoming_call'] as Map<String, dynamic>?;
    if (incomingCallData == null || context == null) return;

    final caller = UserModel(
      uid: incomingCallData['caller']['uid'],
      name: incomingCallData['caller']['name'],
      email: incomingCallData['caller']['email'],
    );

    final channelName = incomingCallData['channelName'] as String;
    final incomingCall = IncomingCallModel(
      caller: caller,
      channelName: channelName,
    );

    // Show incoming call dialog
    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.lightBlue.shade100,
              radius: 40,
              child: Text(
                caller.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.lightBlue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${caller.name} is calling...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Handle call decline through cubit
            },
            icon: const Icon(Icons.call_end, color: Colors.red),
            label: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Handle call acceptance through cubit
              _navigateToAcceptCall(data);
            },
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToHome() async {
    if (router == null) return;
    router!.popUntil((d) => d.isFirst);
    await router!.replace(const HomeRoute());
  }

  UserModel _getCurrentUser() {
    // TODO: Get current user from auth state or storage
    // This is a placeholder - you should implement proper user retrieval
    return UserModel(uid: "current_user", name: "Current User", email: "");
  }
}
