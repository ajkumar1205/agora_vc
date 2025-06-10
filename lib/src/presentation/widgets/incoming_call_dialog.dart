import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/presentation/screens/video_call_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class IncomingCallDialog extends StatelessWidget {
  final IncomingCallModel incomingCall;
  final UserModel currentUser;

  const IncomingCallDialog({
    super.key,
    required this.incomingCall,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_in_talk, size: 50, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Incoming Call',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 40,
              child: Text(
                incomingCall.caller.name[0],
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              incomingCall.caller.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'is calling you...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject call
                ElevatedButton.icon(
                  onPressed: () {
                    context.router.pop();
                  },
                  icon: const Icon(Icons.call_end),
                  label: const Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                // Accept call
                ElevatedButton.icon(
                  onPressed: () {
                    context.router.pop();
                    context.router.push(
                      VideoCallRoute(
                        currentUser: currentUser,
                        targetUser: incomingCall.caller,
                        channelName: incomingCall.channelName,
                        isCaller: false,
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
