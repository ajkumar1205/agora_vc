import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_vc/src/core/services/call_signaling_service.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/core/utils/functions.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

part 'video_call_cubit.freezed.dart';

@freezed
class VideoCallState with _$VideoCallState {
  const factory VideoCallState.initial() = VideoCallInitial;
  const factory VideoCallState.permissionRequesting() = VideoCallPermissionRequesting;
  const factory VideoCallState.permissionDenied(String message) = VideoCallPermissionDenied;
  const factory VideoCallState.initializing() = VideoCallInitializing;
  const factory VideoCallState.connecting() = VideoCallConnecting;
  const factory VideoCallState.ringing({
    required UserModel targetUser,
    required String channelName,
    required bool isOutgoing,
  }) = VideoCallRinging;
  const factory VideoCallState.connected({
    required UserModel targetUser,
    required String channelName,
    required int? remoteUid,
    required bool isVideoEnabled,
    required bool isAudioEnabled,
    required bool isSpeakerEnabled,
    required bool isFrontCamera,
    required int callDuration,
    required NetworkQuality networkQuality,
  }) = VideoCallConnected;
  const factory VideoCallState.reconnecting() = VideoCallReconnecting;
  const factory VideoCallState.ended({
    required CallEndReason reason,
    required int callDuration,
  }) = VideoCallEnded;
  const factory VideoCallState.error({
    required String message,
    required Exception exception,
  }) = VideoCallError;
  const factory VideoCallState.incomingCall({
    required IncomingCallModel incomingCall,
  }) = VideoCallIncomingCall;
}

enum CallEndReason {
  userEnded,
  remoteEnded,
  networkError,
  permissionError,
  timeout,
  declined,
  busy,
}

enum NetworkQuality {
  unknown,
  excellent,
  good,
  poor,
  bad,
  vBad,
  down,
}

class VideoCallCubit extends Cubit<VideoCallState> {
  final CallSignalingService _signalingService;
  
  RtcEngine? _rtcEngine;
  UserModel? _currentUser;
  UserModel? _targetUser;
  String? _channelName;
  int? _remoteUid;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isFrontCamera = true;
  int _callDuration = 0;
  NetworkQuality _networkQuality = NetworkQuality.unknown;
  Timer? _callTimer;
  Timer? _ringTimeout;
  
  StreamSubscription? _incomingCallSubscription;
  StreamSubscription? _callStatusSubscription;
  StreamSubscription? _errorSubscription;

  VideoCallCubit({required CallSignalingService signalingService})
      : _signalingService = signalingService,
        super(const VideoCallState.initial()) {
    _setupSignalingListeners();
  }

  void _setupSignalingListeners() {
    _incomingCallSubscription = _signalingService.incomingCallStream.listen(
      (incomingCall) {
        if (state is VideoCallInitial || state is VideoCallError) {
          emit(VideoCallState.incomingCall(incomingCall: incomingCall));
        }
      },
    );

    _callStatusSubscription = _signalingService.callStatusStream.listen(
      (status) {
        _handleCallStatus(status);
      },
    );

    _errorSubscription = _signalingService.errorStream.listen(
      (error) {
        emit(VideoCallState.error(
          message: error.toString(),
          exception: error,
        ));
      },
    );
  }

  void _handleCallStatus(String status) {
    debugPrint("📞 Call status: $status");
    switch (status) {
      case 'call_declined':
        _endCall(CallEndReason.declined);
        break;
      case 'call_ended_by_remote':
        _endCall(CallEndReason.remoteEnded);
        break;
      case 'poor_network':
        _networkQuality = NetworkQuality.poor;
        _updateConnectedState();
        break;
      case 'good_network':
        _networkQuality = NetworkQuality.good;
        _updateConnectedState();
        break;
    }
  }

  Future<void> initializeVideoCall(UserModel currentUser) async {
    if (!_signalingService.isInitialized) {
      emit(VideoCallState.initializing());
      final success = await _signalingService.initialize(currentUser);
      if (!success) {
        emit(VideoCallState.error(
          message: 'Failed to initialize signaling service',
          exception: Exception('Signaling initialization failed'),
        ));
        return;
      }
    }
    _currentUser = currentUser;
    emit(const VideoCallState.initial());
  }

  Future<void> makeCall(UserModel targetUser) async {
    if (_currentUser == null) {
      emit(VideoCallState.error(
        message: 'Current user not set',
        exception: Exception('Current user not initialized'),
      ));
      return;
    }

    await _requestPermissions();
    if (state is VideoCallPermissionDenied) return;

    _targetUser = targetUser;
    _channelName = '${_currentUser!.id}_${targetUser.id}_${DateTime.now().millisecondsSinceEpoch}';

    emit(VideoCallState.initializing());

    try {
      await _initializeRtcEngine();
      
      emit(VideoCallState.ringing(
        targetUser: targetUser,
        channelName: _channelName!,
        isOutgoing: true,
      ));

      final success = await _signalingService.sendCallRequest(
        _currentUser!,
        targetUser,
        _channelName!,
      );

      if (!success) {
        emit(VideoCallState.error(
          message: 'Failed to send call request',
          exception: Exception('Call request failed'),
        ));
        return;
      }

      // Set timeout for ringing
      _ringTimeout = Timer(const Duration(seconds: 30), () {
        if (state is VideoCallRinging) {
          _endCall(CallEndReason.timeout);
        }
      });

    } catch (e) {
      emit(VideoCallState.error(
        message: 'Failed to initialize call: $e',
        exception: Exception(e),
      ));
    }
  }

  Future<void> acceptCall(IncomingCallModel incomingCall) async {
    _targetUser = incomingCall.caller;
    _channelName = incomingCall.channelName;

    await _requestPermissions();
    if (state is VideoCallPermissionDenied) return;

    emit(VideoCallState.initializing());

    try {
      await _initializeRtcEngine();
      
      final success = await _signalingService.sendCallResponse(
        incomingCall.caller.id!,
        incomingCall.channelName,
        true,
      );

      if (success) {
        await _joinChannel();
      } else {
        emit(VideoCallState.error(
          message: 'Failed to accept call',
          exception: Exception('Call acceptance failed'),
        ));
      }
    } catch (e) {
      emit(VideoCallState.error(
        message: 'Failed to accept call: $e',
        exception: Exception(e),
      ));
    }
  }

  Future<void> declineCall(IncomingCallModel incomingCall) async {
    await _signalingService.sendCallResponse(
      incomingCall.caller.id!,
      incomingCall.channelName,
      false,
    );
    emit(const VideoCallState.initial());
  }

  Future<void> _requestPermissions() async {
    emit(VideoCallState.permissionRequesting());

    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      emit(VideoCallState.permissionDenied('Microphone permission is required'));
      return;
    }

    if (statuses[Permission.camera] != PermissionStatus.granted) {
      emit(VideoCallState.permissionDenied('Camera permission is required'));
      return;
    }
  }

  Future<void> _initializeRtcEngine() async {
    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _rtcEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ Joined channel: ${connection.channelId}");
          _startCallTimer();
          _updateConnectedState();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 Remote user $remoteUid joined");
          _remoteUid = remoteUid;
          _ringTimeout?.cancel();
          _updateConnectedState();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("👋 Remote user $remoteUid left: $reason");
          _remoteUid = null;
          _endCall(CallEndReason.remoteEnded);
        },
        onConnectionStateChanged: (RtcConnection connection, 
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint("🔗 Connection state: $state, reason: $reason");
          switch (state) {
            case ConnectionStateType.connectionStateConnecting:
              emit(VideoCallState.connecting());
              break;
            case ConnectionStateType.connectionStateReconnecting:
              emit(VideoCallState.reconnecting());
              break;
            case ConnectionStateType.connectionStateFailed:
              _endCall(CallEndReason.networkError);
              break;
            case ConnectionStateType.connectionStateDisconnected:
              if (state is VideoCallConnected) {
                _endCall(CallEndReason.networkError);
              }
              break;
            default:
              break;
          }
        },
        onNetworkQuality: (RtcConnection connection, int remoteUid,
            QualityType txQuality, QualityType rxQuality) {
          _networkQuality = _mapQualityToNetworkQuality(txQuality, rxQuality);
          if (this.state is VideoCallConnected) {
            _updateConnectedState();
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("❌ RTC Error: $err - $msg");
          emit(VideoCallState.error(
            message: 'RTC Error: $msg',
            exception: Exception('RTC Error: $err - $msg'),
          ));
        },
      ),
    );

    await _rtcEngine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _rtcEngine!.enableVideo();
    await _rtcEngine!.enableAudio();
    await _rtcEngine!.startPreview();
  }

  Future<void> _joinChannel() async {
    if (_rtcEngine == null || _channelName == null || _currentUser == null) return;

    await _rtcEngine!.joinChannel(
      token: token,
      channelId: _channelName!,
      uid: uidToNumber(_currentUser!.id!),
      options: const ChannelMediaOptions(),
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration++;
      if (state is VideoCallConnected) {
        _updateConnectedState();
      }
    });
  }

  void _updateConnectedState() {
    if (_targetUser != null && _channelName != null) {
      emit(VideoCallState.connected(
        targetUser: _targetUser!,
        channelName: _channelName!,
        remoteUid: _remoteUid,
        isVideoEnabled: _isVideoEnabled,
        isAudioEnabled: _isAudioEnabled,
        isSpeakerEnabled: _isSpeakerEnabled,
        isFrontCamera: _isFrontCamera,
        callDuration: _callDuration,
        networkQuality: _networkQuality,
      ));
    }
  }

  NetworkQuality _mapQualityToNetworkQuality(QualityType tx, QualityType rx) {
    final worst = tx.index > rx.index ? tx : rx;
    switch (worst) {
      case QualityType.qualityExcellent:
        return NetworkQuality.excellent;
      case QualityType.qualityGood:
        return NetworkQuality.good;
      case QualityType.qualityPoor:
        return NetworkQuality.poor;
      case QualityType.qualityBad:
        return NetworkQuality.bad;
      case QualityType.qualityVbad:
        return NetworkQuality.vBad;
      case QualityType.qualityDown:
        return NetworkQuality.down;
      default:
        return NetworkQuality.unknown;
    }
  }

  Future<void> toggleVideo() async {
    if (_rtcEngine == null) return;
    
    _isVideoEnabled = !_isVideoEnabled;
    await _rtcEngine!.enableLocalVideo(_isVideoEnabled);
    _updateConnectedState();
  }

  Future<void> toggleAudio() async {
    if (_rtcEngine == null) return;
    
    _isAudioEnabled = !_isAudioEnabled;
    await _rtcEngine!.enableLocalAudio(_isAudioEnabled);
    _updateConnectedState();
  }

  Future<void> toggleSpeaker() async {
    if (_rtcEngine == null) return;
    
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await _rtcEngine!.setEnableSpeakerphone(_isSpeakerEnabled);
    _updateConnectedState();
  }

  Future<void> switchCamera() async {
    if (_rtcEngine == null) return;
    
    await _rtcEngine!.switchCamera();
    _isFrontCamera = !_isFrontCamera;
    _updateConnectedState();
  }

  Future<void> endCall() async {
    _endCall(CallEndReason.userEnded);
  }

  void _endCall(CallEndReason reason) async {
    _ringTimeout?.cancel();
    _callTimer?.cancel();

    if (_channelName != null && _targetUser != null) {
      await _signalingService.endCall(_channelName!, _targetUser!.id!);
    }

    await _disposeRtcEngine();

    emit(VideoCallState.ended(
      reason: reason,
      callDuration: _callDuration,
    ));

    // Reset state after showing end screen
    Timer(const Duration(seconds: 3), () {
      if (state is VideoCallEnded) {
        emit(const VideoCallState.initial());
      }
    });
  }

  Future<void> _disposeRtcEngine() async {
    if (_rtcEngine != null) {
      await _rtcEngine!.leaveChannel();
      await _rtcEngine!.release();
      _rtcEngine = null;
    }
    _remoteUid = null;
    _channelName = null;
    _targetUser = null;
    _callDuration = 0;
    _isVideoEnabled = true;
    _isAudioEnabled = true;
    _isSpeakerEnabled = true;
    _isFrontCamera = true;
    _networkQuality = NetworkQuality.unknown;
  }

  @override
  Future<void> close() async {
    await _incomingCallSubscription?.cancel();
    await _callStatusSubscription?.cancel();
    await _errorSubscription?.cancel();
    _ringTimeout?.cancel();
    _callTimer?.cancel();
    await _disposeRtcEngine();
    return super.close();
  }
}