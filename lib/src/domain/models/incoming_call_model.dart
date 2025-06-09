import 'package:agora_vc/src/domain/models/user_model.dart';

class IncomingCallModel {
  final UserModel caller;
  final String channelName;

  IncomingCallModel({required this.caller, required this.channelName});
}
