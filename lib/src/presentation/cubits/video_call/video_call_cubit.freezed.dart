// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_call_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoCallState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState()';
}


}

/// @nodoc
class $VideoCallStateCopyWith<$Res>  {
$VideoCallStateCopyWith(VideoCallState _, $Res Function(VideoCallState) __);
}


/// @nodoc


class VideoCallInitial implements VideoCallState {
  const VideoCallInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState.initial()';
}


}




/// @nodoc


class VideoCallPermissionRequesting implements VideoCallState {
  const VideoCallPermissionRequesting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallPermissionRequesting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState.permissionRequesting()';
}


}




/// @nodoc


class VideoCallPermissionDenied implements VideoCallState {
  const VideoCallPermissionDenied(this.message);
  

 final  String message;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallPermissionDeniedCopyWith<VideoCallPermissionDenied> get copyWith => _$VideoCallPermissionDeniedCopyWithImpl<VideoCallPermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallPermissionDenied&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VideoCallState.permissionDenied(message: $message)';
}


}

/// @nodoc
abstract mixin class $VideoCallPermissionDeniedCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallPermissionDeniedCopyWith(VideoCallPermissionDenied value, $Res Function(VideoCallPermissionDenied) _then) = _$VideoCallPermissionDeniedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VideoCallPermissionDeniedCopyWithImpl<$Res>
    implements $VideoCallPermissionDeniedCopyWith<$Res> {
  _$VideoCallPermissionDeniedCopyWithImpl(this._self, this._then);

  final VideoCallPermissionDenied _self;
  final $Res Function(VideoCallPermissionDenied) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(VideoCallPermissionDenied(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VideoCallInitializing implements VideoCallState {
  const VideoCallInitializing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallInitializing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState.initializing()';
}


}




/// @nodoc


class VideoCallConnecting implements VideoCallState {
  const VideoCallConnecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState.connecting()';
}


}




/// @nodoc


class VideoCallRinging implements VideoCallState {
  const VideoCallRinging({required this.targetUser, required this.channelName, required this.isOutgoing});
  

 final  UserModel targetUser;
 final  String channelName;
 final  bool isOutgoing;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallRingingCopyWith<VideoCallRinging> get copyWith => _$VideoCallRingingCopyWithImpl<VideoCallRinging>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallRinging&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.isOutgoing, isOutgoing) || other.isOutgoing == isOutgoing));
}


@override
int get hashCode => Object.hash(runtimeType,targetUser,channelName,isOutgoing);

@override
String toString() {
  return 'VideoCallState.ringing(targetUser: $targetUser, channelName: $channelName, isOutgoing: $isOutgoing)';
}


}

/// @nodoc
abstract mixin class $VideoCallRingingCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallRingingCopyWith(VideoCallRinging value, $Res Function(VideoCallRinging) _then) = _$VideoCallRingingCopyWithImpl;
@useResult
$Res call({
 UserModel targetUser, String channelName, bool isOutgoing
});


$UserModelCopyWith<$Res> get targetUser;

}
/// @nodoc
class _$VideoCallRingingCopyWithImpl<$Res>
    implements $VideoCallRingingCopyWith<$Res> {
  _$VideoCallRingingCopyWithImpl(this._self, this._then);

  final VideoCallRinging _self;
  final $Res Function(VideoCallRinging) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetUser = null,Object? channelName = null,Object? isOutgoing = null,}) {
  return _then(VideoCallRinging(
targetUser: null == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as UserModel,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,isOutgoing: null == isOutgoing ? _self.isOutgoing : isOutgoing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get targetUser {
  
  return $UserModelCopyWith<$Res>(_self.targetUser, (value) {
    return _then(_self.copyWith(targetUser: value));
  });
}
}

/// @nodoc


class VideoCallConnected implements VideoCallState {
  const VideoCallConnected({required this.targetUser, required this.channelName, required this.remoteUid, required this.isVideoEnabled, required this.isAudioEnabled, required this.isSpeakerEnabled, required this.isFrontCamera, required this.callDuration, required this.networkQuality});
  

 final  UserModel targetUser;
 final  String channelName;
 final  int? remoteUid;
 final  bool isVideoEnabled;
 final  bool isAudioEnabled;
 final  bool isSpeakerEnabled;
 final  bool isFrontCamera;
 final  int callDuration;
 final  NetworkQuality networkQuality;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallConnectedCopyWith<VideoCallConnected> get copyWith => _$VideoCallConnectedCopyWithImpl<VideoCallConnected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallConnected&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.remoteUid, remoteUid) || other.remoteUid == remoteUid)&&(identical(other.isVideoEnabled, isVideoEnabled) || other.isVideoEnabled == isVideoEnabled)&&(identical(other.isAudioEnabled, isAudioEnabled) || other.isAudioEnabled == isAudioEnabled)&&(identical(other.isSpeakerEnabled, isSpeakerEnabled) || other.isSpeakerEnabled == isSpeakerEnabled)&&(identical(other.isFrontCamera, isFrontCamera) || other.isFrontCamera == isFrontCamera)&&(identical(other.callDuration, callDuration) || other.callDuration == callDuration)&&(identical(other.networkQuality, networkQuality) || other.networkQuality == networkQuality));
}


@override
int get hashCode => Object.hash(runtimeType,targetUser,channelName,remoteUid,isVideoEnabled,isAudioEnabled,isSpeakerEnabled,isFrontCamera,callDuration,networkQuality);

@override
String toString() {
  return 'VideoCallState.connected(targetUser: $targetUser, channelName: $channelName, remoteUid: $remoteUid, isVideoEnabled: $isVideoEnabled, isAudioEnabled: $isAudioEnabled, isSpeakerEnabled: $isSpeakerEnabled, isFrontCamera: $isFrontCamera, callDuration: $callDuration, networkQuality: $networkQuality)';
}


}

/// @nodoc
abstract mixin class $VideoCallConnectedCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallConnectedCopyWith(VideoCallConnected value, $Res Function(VideoCallConnected) _then) = _$VideoCallConnectedCopyWithImpl;
@useResult
$Res call({
 UserModel targetUser, String channelName, int? remoteUid, bool isVideoEnabled, bool isAudioEnabled, bool isSpeakerEnabled, bool isFrontCamera, int callDuration, NetworkQuality networkQuality
});


$UserModelCopyWith<$Res> get targetUser;

}
/// @nodoc
class _$VideoCallConnectedCopyWithImpl<$Res>
    implements $VideoCallConnectedCopyWith<$Res> {
  _$VideoCallConnectedCopyWithImpl(this._self, this._then);

  final VideoCallConnected _self;
  final $Res Function(VideoCallConnected) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetUser = null,Object? channelName = null,Object? remoteUid = freezed,Object? isVideoEnabled = null,Object? isAudioEnabled = null,Object? isSpeakerEnabled = null,Object? isFrontCamera = null,Object? callDuration = null,Object? networkQuality = null,}) {
  return _then(VideoCallConnected(
targetUser: null == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as UserModel,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,remoteUid: freezed == remoteUid ? _self.remoteUid : remoteUid // ignore: cast_nullable_to_non_nullable
as int?,isVideoEnabled: null == isVideoEnabled ? _self.isVideoEnabled : isVideoEnabled // ignore: cast_nullable_to_non_nullable
as bool,isAudioEnabled: null == isAudioEnabled ? _self.isAudioEnabled : isAudioEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerEnabled: null == isSpeakerEnabled ? _self.isSpeakerEnabled : isSpeakerEnabled // ignore: cast_nullable_to_non_nullable
as bool,isFrontCamera: null == isFrontCamera ? _self.isFrontCamera : isFrontCamera // ignore: cast_nullable_to_non_nullable
as bool,callDuration: null == callDuration ? _self.callDuration : callDuration // ignore: cast_nullable_to_non_nullable
as int,networkQuality: null == networkQuality ? _self.networkQuality : networkQuality // ignore: cast_nullable_to_non_nullable
as NetworkQuality,
  ));
}

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get targetUser {
  
  return $UserModelCopyWith<$Res>(_self.targetUser, (value) {
    return _then(_self.copyWith(targetUser: value));
  });
}
}

/// @nodoc


class VideoCallReconnecting implements VideoCallState {
  const VideoCallReconnecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallReconnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideoCallState.reconnecting()';
}


}




/// @nodoc


class VideoCallEnded implements VideoCallState {
  const VideoCallEnded({required this.reason, required this.callDuration});
  

 final  CallEndReason reason;
 final  int callDuration;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallEndedCopyWith<VideoCallEnded> get copyWith => _$VideoCallEndedCopyWithImpl<VideoCallEnded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallEnded&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.callDuration, callDuration) || other.callDuration == callDuration));
}


@override
int get hashCode => Object.hash(runtimeType,reason,callDuration);

@override
String toString() {
  return 'VideoCallState.ended(reason: $reason, callDuration: $callDuration)';
}


}

/// @nodoc
abstract mixin class $VideoCallEndedCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallEndedCopyWith(VideoCallEnded value, $Res Function(VideoCallEnded) _then) = _$VideoCallEndedCopyWithImpl;
@useResult
$Res call({
 CallEndReason reason, int callDuration
});




}
/// @nodoc
class _$VideoCallEndedCopyWithImpl<$Res>
    implements $VideoCallEndedCopyWith<$Res> {
  _$VideoCallEndedCopyWithImpl(this._self, this._then);

  final VideoCallEnded _self;
  final $Res Function(VideoCallEnded) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? callDuration = null,}) {
  return _then(VideoCallEnded(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CallEndReason,callDuration: null == callDuration ? _self.callDuration : callDuration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class VideoCallError implements VideoCallState {
  const VideoCallError({required this.message, required this.exception});
  

 final  String message;
 final  Exception exception;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallErrorCopyWith<VideoCallError> get copyWith => _$VideoCallErrorCopyWithImpl<VideoCallError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallError&&(identical(other.message, message) || other.message == message)&&(identical(other.exception, exception) || other.exception == exception));
}


@override
int get hashCode => Object.hash(runtimeType,message,exception);

@override
String toString() {
  return 'VideoCallState.error(message: $message, exception: $exception)';
}


}

/// @nodoc
abstract mixin class $VideoCallErrorCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallErrorCopyWith(VideoCallError value, $Res Function(VideoCallError) _then) = _$VideoCallErrorCopyWithImpl;
@useResult
$Res call({
 String message, Exception exception
});




}
/// @nodoc
class _$VideoCallErrorCopyWithImpl<$Res>
    implements $VideoCallErrorCopyWith<$Res> {
  _$VideoCallErrorCopyWithImpl(this._self, this._then);

  final VideoCallError _self;
  final $Res Function(VideoCallError) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? exception = null,}) {
  return _then(VideoCallError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,exception: null == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

/// @nodoc


class VideoCallIncomingCall implements VideoCallState {
  const VideoCallIncomingCall({required this.incomingCall});
  

 final  IncomingCallModel incomingCall;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallIncomingCallCopyWith<VideoCallIncomingCall> get copyWith => _$VideoCallIncomingCallCopyWithImpl<VideoCallIncomingCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallIncomingCall&&(identical(other.incomingCall, incomingCall) || other.incomingCall == incomingCall));
}


@override
int get hashCode => Object.hash(runtimeType,incomingCall);

@override
String toString() {
  return 'VideoCallState.incomingCall(incomingCall: $incomingCall)';
}


}

/// @nodoc
abstract mixin class $VideoCallIncomingCallCopyWith<$Res> implements $VideoCallStateCopyWith<$Res> {
  factory $VideoCallIncomingCallCopyWith(VideoCallIncomingCall value, $Res Function(VideoCallIncomingCall) _then) = _$VideoCallIncomingCallCopyWithImpl;
@useResult
$Res call({
 IncomingCallModel incomingCall
});




}
/// @nodoc
class _$VideoCallIncomingCallCopyWithImpl<$Res>
    implements $VideoCallIncomingCallCopyWith<$Res> {
  _$VideoCallIncomingCallCopyWithImpl(this._self, this._then);

  final VideoCallIncomingCall _self;
  final $Res Function(VideoCallIncomingCall) _then;

/// Create a copy of VideoCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incomingCall = null,}) {
  return _then(VideoCallIncomingCall(
incomingCall: null == incomingCall ? _self.incomingCall : incomingCall // ignore: cast_nullable_to_non_nullable
as IncomingCallModel,
  ));
}


}

// dart format on
