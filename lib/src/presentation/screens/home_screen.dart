import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:agora_vc/src/core/services/call_signaling_service.dart';
import 'package:agora_vc/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/user/user_cubit.dart';
import 'package:agora_vc/src/presentation/cubits/video_call/video_call_cubit.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  UserModel? _targetUser;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
      _initializeServices();
    }
  }

  void _initializeServices() {
    // Only initialize services when we have a valid authenticated user
    if (_currentUser != null) {
      context.read<UserCubit>().getUsers();
      // Initialize video call service with current user
      GetIt.I<CallSignalingService>().initialize(_currentUser!).then((success) {
        if (success) {
          context.read<VideoCallCubit>().initializeVideoCall();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to initialize call service. Please try logging in again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  void _startVideoCall(String userId, String userName) {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to make calls'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final targetUser = UserModel(uid: userId, name: userName, email: "");
    context.read<VideoCallCubit>().makeCall(targetUser);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
                context.router.replace(const LoginRoute());
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _refreshUsers() {
    context.read<UserCubit>().getUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refreshing users list'),
        backgroundColor: Colors.lightBlue.shade600,
      ),
    );
  }

  void _showIncomingCallDialog() {
    final videoCallState = context.read<VideoCallCubit>().state;
    if (videoCallState is VideoCallIncomingCall) {
      showDialog(
        context: context,
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
                  videoCallState.incomingCall.caller.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.lightBlue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${videoCallState.incomingCall.caller.name} is calling...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VideoCallCubit>().declineCall(
                  videoCallState.incomingCall,
                );
              },
              icon: const Icon(Icons.call_end, color: Colors.red),
              label: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VideoCallCubit>().acceptCall(
                  videoCallState.incomingCall,
                );
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
  }

  Widget _buildNetworkQualityIndicator(NetworkQuality quality) {
    Color color;
    String text;
    IconData icon;

    switch (quality) {
      case NetworkQuality.excellent:
        color = Colors.green;
        text = 'Excellent';
        icon = Icons.signal_cellular_4_bar;
        break;
      case NetworkQuality.good:
        color = Colors.lightGreen;
        text = 'Good';
        icon = Icons.signal_cellular_4_bar;
        break;
      case NetworkQuality.poor:
        color = Colors.orange;
        text = 'Poor';
        icon = Icons.signal_cellular_alt_2_bar;
        break;
      case NetworkQuality.bad:
        color = Colors.red;
        text = 'Bad';
        icon = Icons.signal_cellular_alt_1_bar;
        break;
      case NetworkQuality.vBad:
        color = Colors.red.shade700;
        text = 'Very Bad';
        icon = Icons.signal_cellular_0_bar;
        break;
      case NetworkQuality.down:
        color = Colors.red.shade900;
        text = 'No Signal';
        icon = Icons.signal_cellular_off;
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        icon = Icons.signal_cellular_null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _currentUser = state.user;
          _initializeServices();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue.shade600,
          foregroundColor: Colors.white,
          title: const Text(
            'Video Call App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<VideoCallCubit, VideoCallState>(
              builder: (context, videoCallState) {
                if (videoCallState is VideoCallConnected) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildNetworkQualityIndicator(
                      videoCallState.networkQuality,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<VideoCallCubit, VideoCallState>(
              listener: (context, state) {
                if (state is VideoCallIncomingCall) {
                  _showIncomingCallDialog();
                } else if (state is VideoCallConnected ||
                    state is VideoCallRinging ||
                    state is VideoCallConnecting ||
                    state is VideoCallReconnecting) {
                  // Navigate to video call screen
                  context.router.push(
                    VideoCallRoute(
                      currentUser: _currentUser!,
                      targetUser: state is VideoCallConnected
                          ? state.targetUser
                          : state is VideoCallRinging
                          ? state.targetUser
                          : UserModel(uid: "", name: "", email: ""),
                      channelName: state is VideoCallConnected
                          ? state.channelName
                          : state is VideoCallRinging
                          ? state.channelName
                          : "",
                      isCaller: state is VideoCallRinging
                          ? state.isOutgoing
                          : false,
                    ),
                  );
                } else if (state is VideoCallError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<VideoCallCubit>().initializeVideoCall();
                        },
                      ),
                    ),
                  );
                } else if (state is VideoCallPermissionDenied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.orange,
                      action: SnackBarAction(
                        label: 'Settings',
                        textColor: Colors.white,
                        onPressed: () {
                          // Open app settings
                        },
                      ),
                    ),
                  );
                } else if (state is VideoCallEnded) {
                  String message;
                  switch (state.reason) {
                    case CallEndReason.userEnded:
                      message = 'Call ended';
                      break;
                    case CallEndReason.remoteEnded:
                      message =
                          'Call ended by ${_targetUser?.name ?? 'other user'}';
                      break;
                    case CallEndReason.declined:
                      message = 'Call declined';
                      break;
                    case CallEndReason.timeout:
                      message = 'Call timeout - no answer';
                      break;
                    case CallEndReason.networkError:
                      message = 'Call ended due to network error';
                      break;
                    case CallEndReason.permissionError:
                      message = 'Call ended due to permission error';
                      break;
                    default:
                      message = 'Call ended';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.grey.shade600,
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserInitial) {
                return const Center(
                  child: Text('Welcome! Pull down to refresh users.'),
                );
              } else if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UserLoaded) {
                final users = state.users;

                return Column(
                  children: [
                    // Status Banner
                    BlocBuilder<VideoCallCubit, VideoCallState>(
                      builder: (context, videoCallState) {
                        if (videoCallState is VideoCallInitializing) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: Colors.orange.shade100,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Initializing video call service...',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (videoCallState is VideoCallError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: Colors.red.shade100,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Video call service error: ${videoCallState.message}',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Users List
                    Expanded(
                      child: (users.length <= 1)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No users available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check back later for available users',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<UserCubit>().getUsers();
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  if (user.id == _currentUser?.id) {
                                    return SizedBox.shrink(
                                      key: ValueKey(_currentUser?.id),
                                    );
                                  }
                                  return Container(
                                    key: ValueKey(user.id),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.lightBlue.shade100,
                                        radius: 24,
                                        child: Text(
                                          user.name
                                              .split(' ')
                                              .map((e) => e[0])
                                              .join(),
                                          style: TextStyle(
                                            color: Colors.lightBlue.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing:
                                          BlocBuilder<
                                            VideoCallCubit,
                                            VideoCallState
                                          >(
                                            builder: (context, videoCallState) {
                                              final isCallInProgress =
                                                  videoCallState
                                                      is VideoCallConnected ||
                                                  videoCallState
                                                      is VideoCallRinging ||
                                                  videoCallState
                                                      is VideoCallConnecting ||
                                                  videoCallState
                                                      is VideoCallInitializing;

                                              return ElevatedButton.icon(
                                                onPressed: isCallInProgress
                                                    ? null
                                                    : () => _startVideoCall(
                                                        user.id ?? "",
                                                        user.name,
                                                      ),
                                                icon: const Icon(
                                                  Icons.video_call,
                                                  size: 20,
                                                ),
                                                label: Text(
                                                  isCallInProgress
                                                      ? 'Busy'
                                                      : 'Call',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      isCallInProgress
                                                      ? Colors.grey.shade400
                                                      : Colors
                                                            .lightBlue
                                                            .shade600,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              } else if (state is UserError) {
                final error = state.error;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<UserCubit>().getUsers(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text('Welcome! Pull down to refresh users.'),
              );
            },
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Call Logs Button
            FloatingActionButton(
              onPressed: () => context.router.push(const CallLogsRoute()),
              backgroundColor: Colors.lightBlue.shade600,
              heroTag: 'call_logs',
              child: const Icon(Icons.history),
            ),
            const SizedBox(width: 16),
            // Refresh Users Button
            FloatingActionButton(
              onPressed: _refreshUsers,
              backgroundColor: Colors.lightBlue.shade600,
              heroTag: 'refresh',
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
