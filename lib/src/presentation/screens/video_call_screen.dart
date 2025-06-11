import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/core/utils/functions.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


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
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  late RtcEngine _engine;
  Timer? _callTimer;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
          _startCallTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("👋 Remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
              _endCall();
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: uidToNumber(widget.currentUser.id ?? ""),
      options: const ChannelMediaOptions(),
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    _engine.enableLocalVideo(_isVideoEnabled);
  }

  void _toggleAudio() {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    _engine.enableLocalAudio(_isAudioEnabled);
  }

  void _endCall() {
    _callTimer?.cancel();
    context.router.pop();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    _callTimer?.cancel();
    await _engine.leaveChannel();
    await _engine.release();
  }

  Widget _buildVideoView() {
    if (_remoteUid != null) {
      return Stack(
        children: [
          // Remote user's video (full screen)
          Center(child: _remoteVideo()),
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
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
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
              widget.isCaller
                  ? 'Calling ${widget.targetUser.name}...'
                  : 'Connecting...',
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

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildVideoView(),

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
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                    if (_localUserJoined)
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
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
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Toggle video
                    _buildControlButton(
                      icon: _isVideoEnabled
                          ? Icons.videocam
                          : Icons.videocam_off,
                      onPressed: _toggleVideo,
                      backgroundColor: _isVideoEnabled
                          ? Colors.white24
                          : Colors.red,
                    ),

                    // End call
                    _buildControlButton(
                      icon: Icons.call_end,
                      onPressed: _endCall,
                      backgroundColor: Colors.red,
                      size: 60,
                    ),

                    // Toggle audio
                    _buildControlButton(
                      icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                      onPressed: _toggleAudio,
                      backgroundColor: _isAudioEnabled
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
