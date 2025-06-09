import 'dart:async';

import 'package:agora_vc/src/core/services/call_signaling_manager.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user_model.dart';
import 'package:agora_vc/src/presentation/screens/video_call_screen.dart';
import 'package:agora_vc/src/presentation/widgets/incoming_call_dialog.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';


@RoutePage()
class UserSelectionScreen extends StatefulWidget {
  final UserModel currentUser;

  const UserSelectionScreen({super.key, required this.currentUser});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  StreamSubscription<IncomingCallModel>? _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    _incomingCallSubscription = CallSignalingManager().incomingCallStream
        .listen((incomingCall) {
          if (mounted) {
            debugPrint("🔔 Incoming call from ${incomingCall.caller.name}");
            _showIncomingCallDialog(incomingCall);
          }
        });
  }

  void _showIncomingCallDialog(IncomingCallModel incomingCall) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(
        incomingCall: incomingCall,
        currentUser: widget.currentUser,
      ),
    );
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out current user from available users to call
    final usersToCall = availableUsers
        .where((user) => user.id != widget.currentUser.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentUser.name} - Select User to Call'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current user info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    radius: 25,
                    child: Text(
                      widget.currentUser.avatar,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You are:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          widget.currentUser.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          '📡 Listening for incoming calls...',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose someone to call:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: usersToCall.length,
                itemBuilder: (context, index) {
                  final user = usersToCall[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.avatar,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text('ID: ${user.id}'),
                      trailing: ElevatedButton.icon(
                        onPressed: () async {
                          // Create unique channel name for this call
                          String callChannelName =
                              'call_${widget.currentUser.id}_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

                          // Send call request to target user
                          await CallSignalingManager().sendCallRequest(
                            widget.currentUser,
                            user,
                            callChannelName,
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoCallScreen(
                                  currentUser: widget.currentUser,
                                  targetUser: user,
                                  channelName: callChannelName,
                                  isCaller: true,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.video_call),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
