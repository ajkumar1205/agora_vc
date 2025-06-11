import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/core/utils/functions.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallSignalingService {
  static final CallSignalingService _instance = CallSignalingService._internal();
  factory CallSignalingService() => _instance;
  CallSignalingService._internal();

  RtcEngine? _signalingEngine;
  UserModel? _currentUser;
  StreamController<IncomingCallModel>? _incomingCallController;
  StreamController<String>? _callStatusController;
  StreamController<Exception>? _errorController;
  bool _isInitialized = false;

  Stream<IncomingCallModel> get incomingCallStream =>
      _incomingCallController!.stream;
  
  Stream<String> get callStatusStream =>
      _callStatusController!.stream;
      
  Stream<Exception> get errorStream =>
      _errorController!.stream;

  UserModel? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize(UserModel currentUser) async {
    if (_isInitialized) return true;

    try {
      _currentUser = currentUser;
      _incomingCallController = StreamController<IncomingCallModel>.broadcast();
      _callStatusController = StreamController<String>.broadcast();
      _errorController = StreamController<Exception>.broadcast();

      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted ||
          statuses[Permission.camera] != PermissionStatus.granted) {
        _errorController?.add(Exception('Camera and microphone permissions are required'));
        return false;
      }

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
            _callStatusController?.add('signaling_connected');
          },
          onConnectionStateChanged: (RtcConnection connection, 
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("📡 Connection state changed: $state, reason: $reason");
            switch (state) {
              case ConnectionStateType.connectionStateConnecting:
                _callStatusController?.add('connecting');
                break;
              case ConnectionStateType.connectionStateConnected:
                _callStatusController?.add('connected');
                break;
              case ConnectionStateType.connectionStateReconnecting:
                _callStatusController?.add('reconnecting');
                break;
              case ConnectionStateType.connectionStateFailed:
                _errorController?.add(Exception('Connection failed: $reason'));
                break;
              case ConnectionStateType.connectionStateDisconnected:
                _callStatusController?.add('disconnected');
                break;
            }
          },
          onStreamMessage: (RtcConnection connection, int remoteUid, int streamId, Uint8List data, int length, int sentTs) {
            try {
              String message = String.fromCharCodes(data);
              Map<String, dynamic> messageData = json.decode(message);
              debugPrint("📨 Received message: $messageData from user $remoteUid");

              if (messageData['type'] == 'incoming_call') {
                String callerName = messageData['caller_name'];
                String callerId = messageData['caller_id'];
                String channelName = messageData['channel_name'];

                UserModel caller = availableUsers.firstWhere(
                  (user) => user.id == callerId,
                  orElse: () => UserModel(uid: callerId, name: callerName, email: ""),
                );

                _incomingCallController?.add(
                  IncomingCallModel(caller: caller, channelName: channelName),
                );
              } else if (messageData['type'] == 'call_ended') {
                _callStatusController?.add('call_ended_by_remote');
              } else if (messageData['type'] == 'call_declined') {
                _callStatusController?.add('call_declined');
              }
            } catch (e) {
              debugPrint("❌ Error parsing incoming message: $e");
              _errorController?.add(Exception('Failed to parse incoming message: $e'));
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("❌ Signaling Error: $err - $msg");
            _errorController?.add(Exception('Signaling error: $msg'));
          },
          onNetworkQuality: (RtcConnection connection, int remoteUid, QualityType txQuality, QualityType rxQuality) {
            if (txQuality == QualityType.qualityPoor || rxQuality == QualityType.qualityPoor) {
              _callStatusController?.add('poor_network');
            } else if (txQuality == QualityType.qualityGood && rxQuality == QualityType.qualityGood) {
              _callStatusController?.add('good_network');
            }
          },
        ),
      );

      await _signalingEngine!.joinChannel(
        token: token,
        channelId: 'global_signaling',
        uid: uidToNumber(currentUser.id ?? ""),
        options: const ChannelMediaOptions(
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
        ),
      );

      _isInitialized = true;
      debugPrint("📡 Signaling manager initialized for ${currentUser.name}");
      return true;
    } catch (e) {
      debugPrint("❌ Failed to initialize signaling service: $e");
      _errorController?.add(Exception('Failed to initialize signaling: $e'));
      return false;
    }
  }

  Future<bool> sendCallRequest(UserModel caller, UserModel target, String channelName) async {
    if (_signalingEngine == null || !_isInitialized) {
      debugPrint("❌ Signaling engine not initialized");
      _errorController?.add(Exception('Signaling engine not initialized'));
      return false;
    }

    try {
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
      _callStatusController?.add('call_request_sent');
      return true;
    } catch (e) {
      debugPrint("❌ Error sending call request: $e");
      _errorController?.add(Exception('Failed to send call request: $e'));
      return false;
    }
  }

  Future<bool> sendCallResponse(String targetUserId, String channelName, bool accepted) async {
    if (_signalingEngine == null || !_isInitialized) {
      _errorController?.add(Exception('Signaling engine not initialized'));
      return false;
    }

    try {
      Map<String, dynamic> responseData = {
        'type': accepted ? 'call_accepted' : 'call_declined',
        'responder_id': _currentUser?.id,
        'responder_name': _currentUser?.name,
        'target_id': targetUserId,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      String message = json.encode(responseData);
      List<int> messageBytes = utf8.encode(message);
      final list = Uint8List.fromList(messageBytes);

      await _signalingEngine!.sendStreamMessage(
        streamId: 1,
        data: list,
        length: list.length,
      );

      debugPrint("📤 Sent call response: ${accepted ? 'accepted' : 'declined'}");
      return true;
    } catch (e) {
      debugPrint("❌ Error sending call response: $e");
      _errorController?.add(Exception('Failed to send call response: $e'));
      return false;
    }
  }

  Future<bool> endCall(String channelName, String targetUserId) async {
    if (_signalingEngine == null || !_isInitialized) {
      return false;
    }

    try {
      Map<String, dynamic> endCallData = {
        'type': 'call_ended',
        'sender_id': _currentUser?.id,
        'sender_name': _currentUser?.name,
        'target_id': targetUserId,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      String message = json.encode(endCallData);
      List<int> messageBytes = utf8.encode(message);
      final list = Uint8List.fromList(messageBytes);

      await _signalingEngine!.sendStreamMessage(
        streamId: 1,
        data: list,
        length: list.length,
      );

      debugPrint("📤 Sent call end signal");
      return true;
    } catch (e) {
      debugPrint("❌ Error sending call end signal: $e");
      return false;
    }
  }

  void dispose() {
    _incomingCallController?.close();
    _callStatusController?.close();
    _errorController?.close();
    if (_signalingEngine != null) {
      _signalingEngine!.leaveChannel();
      _signalingEngine!.release();
      _signalingEngine = null;
    }
    _isInitialized = false;
    _currentUser = null;
  }
}
