import 'package:cloud_functions/cloud_functions.dart';
import 'package:agora_vc/src/core/utils/constants.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

class CloudFunctionsService {
  static final CloudFunctionsService _instance =
      CloudFunctionsService._internal();
  factory CloudFunctionsService() => _instance;
  CloudFunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateAgoraToken({
    required String channelName,
    required String uid,
  }) async {
    try {
      final result = await _functions.httpsCallable('generateAgoraToken').call({
        'channelName': channelName,
        'uid': uid,
      });

      return result.data['token'] as String;
    } catch (e) {
      throw Exception('Failed to generate Agora token: $e');
    }
  }

  Future<void> sendCallNotification({
    required UserModel caller,
    required UserModel receiver,
    required String channelName,
  }) async {
    try {
      await _functions.httpsCallable('sendCallNotification').call({
        'callerId': caller.id,
        'callerName': caller.name,
        'receiverId': receiver.id,
        'channelName': channelName,
      });
    } catch (e) {
      throw Exception('Failed to send call notification: $e');
    }
  }
}
