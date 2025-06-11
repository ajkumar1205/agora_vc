import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/repositories/user_repository.dart';

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

  UserCubit({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserState.initial());

  Future<void> getUsers() async {
    emit(const UserState.loading());

    try {
      final response = await _userRepository.getUsers();

      if( response is Success<List<UserModel>>){
        emit(UserState.loaded(response.data));
      } else if (response is Failed<List<UserModel>>) {
        emit(UserState.error(response.error));
      }

    } on Exception catch (e) {
      emit(UserState.error(e));
    }
  }

  void resetState() {
    emit(const UserState.initial());
  }

  void clearUsers() {
    emit(const UserState.initial());
  }
}
