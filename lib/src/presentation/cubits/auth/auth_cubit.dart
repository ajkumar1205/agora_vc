import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';

part 'auth_cubit.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserModel user) = AuthAuthenticated;
  const factory AuthState.error(Exception error) = AuthError;
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.initial());

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final response = await _authRepository.createUser(
        name: name,
        email: email,
        password: password,
      );

      if(response is Success<UserModel>) {
        emit(AuthState.authenticated(response.data));
      } else if (response is Failed<UserModel>) {
        emit(AuthState.error(response.error));
      }

      
    } on Exception catch (e) {
      emit(AuthState.error(e));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response is Success<UserModel>) {
        emit(AuthState.authenticated(response.data));
      } else if (response is Failed<UserModel>) {
        emit(AuthState.error(response.error));
      }
      
    } on Exception catch (e) {
      emit(AuthState.error(e));
    }
  }

  void logout() {
    emit(const AuthState.initial());
  }

  void resetState() {
    emit(const AuthState.initial());
  }
}
