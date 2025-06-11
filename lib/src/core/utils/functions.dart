import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';

int uidToNumber(String uid, {int digits = 10}) {
  var bytes = utf8.encode(uid);
  var digest = sha256.convert(bytes);
  var hex = digest.toString();

  // Take first few characters and convert to int
  var firstDigits = hex.substring(0, 15); // 15 hex chars ≈ 10 decimal digits
  return int.parse(firstDigits, radix: 16) % (math.pow(10, digits).toInt());
}
