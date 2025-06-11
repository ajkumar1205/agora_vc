import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';

part 'user_cubit.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = Usernitial;
  const factory UserState.loading() = UserLoading;
  const factory UserState.loaded(List<UserModel> users) = UserLoaded;
  const factory UserState.error(Exception message) = UserError;
}

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  final LocalUserRepository _localUserRepository;

  UserCubit({
    required UserRepository userRepository,
    required LocalUserRepository localUserRepository,
  }) : _userRepository = userRepository,
       _localUserRepository = localUserRepository,
       super(const UserState.initial());

  Future<void> getUsers({bool forceRefresh = false}) async {
    emit(const UserState.loading());

    try {
      // First try to load cached users if not forcing refresh
      if (!forceRefresh) {
        final cachedResponse = await _localUserRepository.getCachedUsers();
        if (cachedResponse is Success<List<UserModel>> &&
            cachedResponse.data.isNotEmpty) {
          emit(UserState.loaded(cachedResponse.data));
          // Continue to fetch fresh data in background
          _fetchAndCacheUsers();
          return;
        }
      }

      // Fetch fresh data from remote
      await _fetchAndCacheUsers();
    } on Exception catch (e) {
      // If remote fails, try to load cached data as fallback
      final cachedResponse = await _localUserRepository.getCachedUsers();
      if (cachedResponse is Success<List<UserModel>> &&
          cachedResponse.data.isNotEmpty) {
        emit(UserState.loaded(cachedResponse.data));
      } else {
        emit(UserState.error(e));
      }
    }
  }

  Future<void> _fetchAndCacheUsers() async {
    try {
      final response = await _userRepository.getUsers();

      if (response is Success<List<UserModel>>) {
        // Cache the users locally
        await _localUserRepository.setCachedUsers(response.data);
        emit(UserState.loaded(response.data));
      } else if (response is Failed<List<UserModel>>) {
        emit(UserState.error(response.error));
      }
    } on Exception catch (e) {
      emit(UserState.error(e));
    }
  }

  Future<void> loadCachedUsers() async {
    try {
      final response = await _localUserRepository.getCachedUsers();

      if (response is Success<List<UserModel>>) {
        if (response.data.isNotEmpty) {
          emit(UserState.loaded(response.data));
        } else {
          emit(const UserState.initial());
        }
      } else {
        emit(const UserState.initial());
      }
    } on Exception catch (e) {
      emit(UserState.error(e));
    }
  }

  Future<void> refreshUsers() async {
    await getUsers(forceRefresh: true);
  }

  void resetState() {
    emit(const UserState.initial());
  }

  void clearUsers() async {
    await _localUserRepository.clearCachedUsers();
    emit(const UserState.initial());
  }
}
