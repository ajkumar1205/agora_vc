import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  // TODO: Replace with your Firebase Server Key
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  Future<bool> sendCallNotification({
    required UserModel caller,
    required UserModel target,
    required String channelName,
    required String targetFCMToken,
  }) async {
    try {
      final notification = {
        'title': 'Incoming Video Call',
        'body': '${caller.name} is calling...',
        'sound': 'default',
        'priority': 'high',
        'android_channel_id': 'video_call_channel',
      };

      final data = {
        'type': 'incoming_call',
        'caller_id': caller.id,
        'caller_name': caller.name,
        'target_id': target.id,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final message = {
        'to': targetFCMToken,
        'notification': notification,
        'data': data,
        'priority': 'high',
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'video_call_channel',
            'priority': 'high',
            'default_sound': true,
            'default_vibrate': true,
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'alert': {
                'title': notification['title'],
                'body': notification['body'],
              },
              'sound': 'default',
              'category': 'CALL_CATEGORY',
              'interruption-level': 'critical',
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM call notification sent successfully');
        return true;
      } else {
        debugPrint('❌ Failed to send FCM notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM notification: $e');
      return false;
    }
  }

  Future<bool> sendCallResponse({
    required String targetFCMToken,
    required String callerId,
    required String channelName,
    required bool accepted,
    required UserModel responder,
  }) async {
    try {
      final data = {
        'type': accepted ? 'call_accepted' : 'call_declined',
        'responder_id': responder.id,
        'responder_name': responder.name,
        'caller_id': callerId,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final message = {'to': targetFCMToken, 'data': data, 'priority': 'high'};

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM call response sent successfully');
        return true;
      } else {
        debugPrint('❌ Failed to send FCM response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM response: $e');
      return false;
    }
  }

  Future<bool> sendCallEndNotification({
    required String targetFCMToken,
    required String callerId,
    required String channelName,
    required UserModel sender,
  }) async {
    try {
      final data = {
        'type': 'call_ended',
        'sender_id': sender.id,
        'sender_name': sender.name,
        'caller_id': callerId,
        'channel_name': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final message = {'to': targetFCMToken, 'data': data, 'priority': 'high'};

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM call end notification sent successfully');
        return true;
      } else {
        debugPrint(
          '❌ Failed to send FCM call end notification: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM call end notification: $e');
      return false;
    }
  }
}
