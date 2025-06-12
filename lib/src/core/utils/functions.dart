import 'dart:developer';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:agora_vc/src/core/utils/constants.dart';

int uidToNumber(String uid, {int digits = 10}) {
  var bytes = utf8.encode(uid);
  var digest = sha256.convert(bytes);
  var hex = digest.toString();

  // Take first few characters and convert to int
  var firstDigits = hex.substring(0, 15); // 15 hex chars ≈ 10 decimal digits
  return int.parse(firstDigits, radix: 16) % (math.pow(10, digits).toInt());
}

Future<String?> generateAgoraToken({
  required String channelName,
  required String uid,
  int role = 1, // Publisher role
}) async {
  if (channelName.isEmpty || uid.isEmpty) {
    log('❌ Invalid parameters: channelName and uid cannot be empty');
    return null;
  }

  try {
    final url = Uri.parse('$cloudFunctionsBaseUrl/generateToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'channelName': channelName, 'uid': uid, 'role': role}),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data == null ||
            !data.containsKey('token') ||
            data['token'] == null) {
          log('❌ Invalid token response format');
          return null;
        }
        log('✅ Agora token generated successfully');
        return data['token'] as String;
      } catch (e) {
        log('❌ Error parsing token response: $e');
        return null;
      }
    } else {
      log(
        '❌ Failed to generate token: ${response.statusCode} - ${response.body}',
      );
      return null;
    }
  } catch (e) {
    log('❌ Network error generating token: $e');
    return null;
  }
}
