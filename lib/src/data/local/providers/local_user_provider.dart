import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:hive_ce/hive.dart';

class LocalUserProvider {
  final configBox = Hive.box("config");
  final usersBox = Hive.box<UserModel>("users");

  Future<UserModel?> getCurrentUser() async {
    return Future.delayed(Duration.zero, () => configBox.get("currentUser") as UserModel?);
  }

  Future<List<UserModel>> getCachedUsers() async {
    return Future.delayed(Duration.zero, () => usersBox.values.toList());
  }

  Future<void> saveCurrentUser(UserModel user) async {
    await Future.delayed(Duration.zero, () => configBox.put("currentUser", user));
  }

  Future<void> clearCurrentUser() async {
    await configBox.delete("currentUser");
  }

  Future<void> setCachedUsers(List<UserModel> users) async {
    await usersBox.clear();
    await usersBox.addAll(users);
  }

  Future<void> clearCachedUsers() async {
    await usersBox.clear();
  }
}
