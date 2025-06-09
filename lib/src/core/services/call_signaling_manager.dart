import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Call signaling manager
class CallSignalingManager {
  static final CallSignalingManager _instance =
      CallSignalingManager._internal();
  factory CallSignalingManager() => _instance;
  CallSignalingManager._internal();

  RtcEngine? _signalingEngine;
  UserModel? _currentUser;
  StreamController<IncomingCallModel>? _incomingCallController;
  bool _isInitialized = false;

  Stream<IncomingCallModel> get incomingCallStream =>
      _incomingCallController!.stream;

  Future<void> initialize(UserModel currentUser) async {
    if (_isInitialized) return;

    _currentUser = currentUser;
    _incomingCallController = StreamController<IncomingCallModel>.broadcast();

    await [Permission.microphone, Permission.camera].request();

    _signalingEngine = createAgoraRtcEngine();
    await _signalingEngine!.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _signalingEngine!.setClientRole(
      role: ClientRoleType.clientRoleAudience,
    );

    _signalingEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("📡 Joined signaling channel: ${connection.channelId}");
        },
        onStreamMessage:
            (
              RtcConnection connection,
              int remoteUid,
              int streamId,
              Uint8List data,
              int length,
              int sentTs,
            ) {
              try {
                String message = String.fromCharCodes(data);
                Map<String, dynamic> messageData = json.decode(message);
                debugPrint(
                  "📨 Received message: $messageData from user $remoteUid",
                );

                if (messageData['type'] == 'incoming_call') {
                  String callerName = messageData['caller_name'];
                  String callerId = messageData['caller_id'];
                  String channelName = messageData['channel_name'];

                  UserModel caller = availableUsers.firstWhere(
                    (user) => user.id == callerId,
                    orElse: () =>
                        UserModel(id: callerId, name: callerName, avatar: '👤'),
                  );

                  _incomingCallController?.add(
                    IncomingCallModel(caller: caller, channelName: channelName),
                  );
                }
              } catch (e) {
                debugPrint("❌ Error parsing incoming message: $e");
              }
            },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("❌ Signaling Error: $err - $msg");
        },
      ),
    );

    // Join the global signaling channel
    await _signalingEngine!.joinChannel(
      token: token,
      channelId: 'global_signaling',
      uid: int.parse(currentUser.id.replaceAll('user', '')),
      options: const ChannelMediaOptions(
        autoSubscribeAudio: false,
        autoSubscribeVideo: false,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
      ),
    );

    _isInitialized = true;
    debugPrint("📡 Signaling manager initialized for ${currentUser.name}");
  }

  Future<void> sendCallRequest(
    UserModel caller,
    UserModel target,
    String channelName,
  ) async {
    if (_signalingEngine == null || !_isInitialized) {
      debugPrint("❌ Signaling engine not initialized");
      return;
    }

    try {
      // Create data stream if not exists
      await _signalingEngine!.createDataStream(
        const DataStreamConfig(syncWithAudio: false, ordered: true),
      );

      Map<String, dynamic> callData = {
        'type': 'incoming_call',
        'caller_id': caller.id,
        'caller_name': caller.name,
        'target_id': target.id,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      String message = json.encode(callData);
      List<int> messageBytes = utf8.encode(message);
      final list = Uint8List.fromList(messageBytes);

      await _signalingEngine!.sendStreamMessage(
        streamId: 1,
        data: list,
        length: list.length,
      );

      debugPrint("📤 Sent call request from ${caller.name} to ${target.name}");
    } catch (e) {
      debugPrint("❌ Error sending call request: $e");
    }
  }

  void dispose() {
    _incomingCallController?.close();
    if (_signalingEngine != null) {
      _signalingEngine!.leaveChannel();
      _signalingEngine!.release();
      _signalingEngine = null;
    }
    _isInitialized = false;
  }
}
