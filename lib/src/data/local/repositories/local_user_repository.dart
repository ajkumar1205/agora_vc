

import 'package:agora_vc/src/data/base_repository.dart';
import 'package:agora_vc/src/data/local/providers/local_user_provider.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';

class LocalUserRepository extends BaseRepository<LocalUserProvider> {
  LocalUserRepository({required super.provider});

  Future<BaseResponseModel<UserModel?>> getCurrentUser() async {
    return await get(provider.getCurrentUser());
  }

  Future<BaseResponseModel<List<UserModel>>> getCachedUsers() async {
    return await get(provider.getCachedUsers());
  }

  Future<BaseResponseModel> saveCurrentUser(UserModel user) async {
    return await get(provider.saveCurrentUser(user));
  }

  Future<BaseResponseModel> clearCurrentUser() async {
    return await get(provider.clearCurrentUser());
  }

  Future<BaseResponseModel> setCachedUsers(List<UserModel> users) async {
    return await get(provider.setCachedUsers(users));
  }

  Future<BaseResponseModel> clearCachedUsers() async {
    return await get(provider.clearCachedUsers());
  }
}