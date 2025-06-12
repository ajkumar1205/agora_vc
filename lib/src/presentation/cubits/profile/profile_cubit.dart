import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';

part 'profile_cubit.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.error(Exception error) = ProfileError;

  const factory ProfileState.loaded(UserModel user) = ProfileLoaded;
  const factory ProfileState.cleared() = ProfileCleared;
}

class ProfileCubit extends Cubit<ProfileState> {
  final LocalUserRepository _localUserRepository;

  ProfileCubit({required LocalUserRepository localUserRepository})
    : _localUserRepository = localUserRepository,
      super(const ProfileState.initial());

  Future<void> getCurrentUser() async {
    emit(const ProfileState.loading());

    try {
      final response = await _localUserRepository.getCurrentUser();

      if (response is Success<UserModel?>) {
        if (response.data != null) {
          emit(ProfileState.loaded(response.data!));
        } else {
          emit(const ProfileState.initial());
        }
      } else if (response is Failed<UserModel?>) {
        emit(ProfileState.error(response.error));
      }
    } on Exception catch (e) {
      emit(ProfileState.error(e));
    }
  }

  Future<void> saveCurrentUser(UserModel user) async {
    emit(const ProfileState.loading());

    try {
      final response = await _localUserRepository.saveCurrentUser(user);

      if (response is Success) {
        emit(ProfileState.loaded(user));
      } else if (response is Failed) {
        emit(ProfileState.error(response.error));
      }
    } on Exception catch (e) {
      emit(ProfileState.error(e));
    }
  }

  Future<void> clearCurrentUser() async {
    emit(const ProfileState.loading());

    try {
      final response = await _localUserRepository.clearCurrentUser();

      if (response is Success) {
        emit(const ProfileState.cleared());
      } else if (response is Failed) {
        emit(ProfileState.error(response.error));
      }
    } on Exception catch (e) {
      emit(ProfileState.error(e));
    }
  }
}
