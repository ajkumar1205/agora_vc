import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@HiveType(typeId: 0)
abstract class UserModel with _$UserModel {
  const factory UserModel({
    @HiveField(0) required String uid,
    @HiveField(1) required String name,
    @HiveField(2) required String email,
    @HiveField(3) String? id,
    @HiveField(4) String? fcmToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
