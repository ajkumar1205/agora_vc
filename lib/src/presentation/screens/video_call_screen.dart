import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/core/utils/functions.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/presentation/cubits/video_call/video_call_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class VideoCallScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel targetUser;
  final String channelName;
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.currentUser,
    required this.targetUser,
    required this.channelName,
    required this.isCaller,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    try {
      // Initialize engine for video rendering
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.startPreview();

      // Get token from cloud function
      final token = await generateAgoraToken(
        channelName: widget.channelName,
        uid: widget.currentUser.id ?? widget.currentUser.uid,
      );

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate token'),
              backgroundColor: Colors.red,
            ),
          );
          context.router.pop();
        }
        return;
      }

      log("🔑 Generated Agora token successfully");
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: uidToNumber(widget.currentUser.id ?? widget.currentUser.uid),
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      log("❌ Error initializing engine: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize video: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.router.pop();
      }
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _endCall() {
    context.read<VideoCallCubit>().endCall();
    context.router.pop();
  }

  @override
  void dispose() {
    _disposeEngine();
    super.dispose();
  }

  Future<void> _disposeEngine() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    }
  }

  Widget _buildVideoView(VideoCallConnected state) {
    if (state.remoteUid != null) {
      return Stack(
        children: [
          // Remote user's video (full screen)
          Center(child: _remoteVideo(state.remoteUid!, state.channelName)),
          // Local user's video (picture-in-picture)
          Positioned(
            width: 120,
            height: 160,
            top: 50,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _engine != null
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          // Network quality indicator
          Positioned(
            top: 60,
            left: 20,
            child: _buildNetworkQualityIndicator(state.networkQuality),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 60,
              child: Text(
                widget.targetUser.name[0],
                style: const TextStyle(fontSize: 60),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Waiting for ${widget.targetUser.name} to join...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      );
    }
  }

  Widget _remoteVideo(int remoteUid, String channelName) {
    if (_engine != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Text(
        'Initializing video...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
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
        color: color.withValues(alpha: 0.1),
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

  Widget _buildCallStateIndicator(VideoCallState state) {
    if (state is VideoCallConnecting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Connecting...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    } else if (state is VideoCallReconnecting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Reconnecting...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCallCubit, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallEnded) {
          // Show end call message and navigate back
          String message;
          switch (state.reason) {
            case CallEndReason.userEnded:
              message = 'Call ended';
              break;
            case CallEndReason.remoteEnded:
              message = 'Call ended by ${widget.targetUser.name}';
              break;
            case CallEndReason.networkError:
              message = 'Call ended due to network error';
              break;
            case CallEndReason.timeout:
              message = 'Call timeout';
              break;
            case CallEndReason.declined:
              message = 'Call declined';
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

          // Navigate back after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.router.pop();
            }
          });
        } else if (state is VideoCallError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Video view based on state
              if (state is VideoCallConnected)
                _buildVideoView(state)
              else if (state is VideoCallConnecting ||
                  state is VideoCallReconnecting)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        radius: 60,
                        child: Text(
                          widget.targetUser.name[0],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        state is VideoCallConnecting
                            ? 'Connecting...'
                            : 'Reconnecting...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        radius: 60,
                        child: Text(
                          widget.targetUser.name[0],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Calling ${widget.targetUser.name}...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),

              // Top bar with user info and call duration
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.targetUser.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state is VideoCallConnected)
                          Text(
                            _formatDuration(state.callDuration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 8),
                        _buildCallStateIndicator(state),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Toggle video
                        _buildControlButton(
                          icon:
                              (state is VideoCallConnected &&
                                  state.isVideoEnabled)
                              ? Icons.videocam
                              : Icons.videocam_off,
                          onPressed: () =>
                              context.read<VideoCallCubit>().toggleVideo(),
                          backgroundColor:
                              (state is VideoCallConnected &&
                                  state.isVideoEnabled)
                              ? Colors.white24
                              : Colors.red,
                        ),

                        // Switch camera
                        if (state is VideoCallConnected && state.isVideoEnabled)
                          _buildControlButton(
                            icon: Icons.cameraswitch,
                            onPressed: () =>
                                context.read<VideoCallCubit>().switchCamera(),
                            backgroundColor: Colors.white24,
                          ),

                        // End call
                        _buildControlButton(
                          icon: Icons.call_end,
                          onPressed: _endCall,
                          backgroundColor: Colors.red,
                          size: 60,
                        ),

                        // Toggle speaker
                        if (state is VideoCallConnected)
                          _buildControlButton(
                            icon: state.isSpeakerEnabled
                                ? Icons.volume_up
                                : Icons.volume_down,
                            onPressed: () =>
                                context.read<VideoCallCubit>().toggleSpeaker(),
                            backgroundColor: state.isSpeakerEnabled
                                ? Colors.white24
                                : Colors.grey,
                          ),

                        // Toggle audio
                        _buildControlButton(
                          icon:
                              (state is VideoCallConnected &&
                                  state.isAudioEnabled)
                              ? Icons.mic
                              : Icons.mic_off,
                          onPressed: () =>
                              context.read<VideoCallCubit>().toggleAudio(),
                          backgroundColor:
                              (state is VideoCallConnected &&
                                  state.isAudioEnabled)
                              ? Colors.white24
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.4),
        onPressed: onPressed,
      ),
    );
  }
}
