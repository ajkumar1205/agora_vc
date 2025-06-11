import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:agora_vc/src/core/services/call_signaling_service.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/presentation/screens/user_selection_screen.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserIdentityScreen extends StatelessWidget {
  const UserIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who are you?'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'First, select who you are:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: availableUsers.length,
                itemBuilder: (context, index) {
                  final user = availableUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          user.name[0],
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
                          // Initialize signaling for this user
                          await CallSignalingService().initialize(user);
                          if (context.mounted) {
                            context.router.replace(
                              UserSelectionRoute(currentUser: user),
                            );
                          }
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Select'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
