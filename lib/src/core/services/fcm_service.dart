import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/core/utils/constants.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static const _timeout = Duration(seconds: 10);
  final _client = http.Client();

  Future<bool> sendCallNotification({
    required UserModel caller,
    required UserModel target,
    required String channelName,
  }) async {
    if (target.fcmToken == null || target.fcmToken!.isEmpty) {
      log('❌ Cannot send call notification: Target FCM token is null or empty');
      return false;
    }

    if (caller.id == null && caller.uid.isEmpty) {
      log('❌ Cannot send call notification: Caller ID is invalid');
      return false;
    }

    try {
      final url = Uri.parse('$cloudFunctionsBaseUrl/sendCallNotification');

      final body = {
        'caller': {'id': caller.id ?? caller.uid, 'name': caller.name},
        'target': {'id': target.id ?? target.uid, 'fcmToken': target.fcmToken},
        'channelName': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            log('✅ Call notification sent successfully via Cloud Functions');
            return true;
          }
          log(
            '❌ Call notification failed: ${responseData['message'] ?? 'Unknown error'}',
          );
          return false;
        } catch (e) {
          log('❌ Error parsing call notification response: $e');
          return false;
        }
      } else {
        log(
          '❌ Failed to send call notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } on TimeoutException {
      log('❌ Call notification request timed out');
      return false;
    } catch (e) {
      log('❌ Error sending call notification: $e');
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
    if (targetFCMToken.isEmpty || callerId.isEmpty) {
      log('❌ Cannot send call response: Invalid target token or caller ID');
      return false;
    }

    try {
      final url = Uri.parse('$cloudFunctionsBaseUrl/sendCallResponse');

      final body = {
        'caller': {'id': callerId, 'fcmToken': targetFCMToken},
        'responder': {
          'id': responder.id ?? responder.uid,
          'name': responder.name,
        },
        'channelName': channelName,
        'accepted': accepted,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            log('✅ Call response sent successfully via Cloud Functions');
            return true;
          }
          log(
            '❌ Call response failed: ${responseData['message'] ?? 'Unknown error'}',
          );
          return false;
        } catch (e) {
          log('❌ Error parsing call response: $e');
          return false;
        }
      } else {
        log(
          '❌ Failed to send call response: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } on TimeoutException {
      log('❌ Call response request timed out');
      return false;
    } catch (e) {
      log('❌ Error sending call response: $e');
      return false;
    }
  }

  Future<bool> sendCallEndNotification({
    required String targetFCMToken,
    required String callerId,
    required String channelName,
    required UserModel sender,
  }) async {
    if (targetFCMToken.isEmpty || callerId.isEmpty) {
      log(
        '❌ Cannot send call end notification: Invalid target token or caller ID',
      );
      return false;
    }

    try {
      final url = Uri.parse('$cloudFunctionsBaseUrl/sendCallEndNotification');

      final body = {
        'caller': {'id': callerId},
        'target': {'fcmToken': targetFCMToken},
        'sender': {'id': sender.id ?? sender.uid, 'name': sender.name},
        'channelName': channelName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            log(
              '✅ Call end notification sent successfully via Cloud Functions',
            );
            return true;
          }
          log(
            '❌ Call end notification failed: ${responseData['message'] ?? 'Unknown error'}',
          );
          return false;
        } catch (e) {
          log('❌ Error parsing call end notification response: $e');
          return false;
        }
      } else {
        log(
          '❌ Failed to send call end notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } on TimeoutException {
      log('❌ Call end notification request timed out');
      return false;
    } catch (e) {
      log('❌ Error sending call end notification: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
