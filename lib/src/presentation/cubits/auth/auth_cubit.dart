import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';
import 'package:agora_vc/src/domain/repositories/auth_repository.dart';
import 'package:agora_vc/src/data/local/repositories/local_user_repository.dart';

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
  final LocalUserRepository _localUserRepository;

  AuthCubit({
    required AuthRepository authRepository,
    required LocalUserRepository localUserRepository,
  }) : _authRepository = authRepository,
       _localUserRepository = localUserRepository,
       super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());

    try {
      final response = await _localUserRepository.getCurrentUser();

      if (response is Success<UserModel?> && response.data != null) {
        emit(AuthState.authenticated(response.data!));
      } else {
        emit(const AuthState.initial());
      }
    } on Exception catch (e) {
      emit(AuthState.error(e));
    }
  }

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

      if (response is Success<UserModel>) {
        // Save user locally after successful creation
        final saveResponse = await _localUserRepository.saveCurrentUser(
          response.data,
        );

        if (saveResponse is Success) {
          emit(AuthState.authenticated(response.data));
        } else {
          // Even if local save fails, user is still authenticated
          emit(AuthState.authenticated(response.data));
        }
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
        // Save user locally after successful login
        final saveResponse = await _localUserRepository.saveCurrentUser(
          response.data,
        );

        if (saveResponse is Success) {
          emit(AuthState.authenticated(response.data));
        } else {
          // Even if local save fails, user is still authenticated
          emit(AuthState.authenticated(response.data));
        }
      } else if (response is Failed<UserModel>) {
        emit(AuthState.error(response.error));
      }
    } on Exception catch (e) {
      emit(AuthState.error(e));
    }
  }

  Future<void> logout() async {
    try {
      // Clear local user data
      await _localUserRepository.clearCurrentUser();
      await _localUserRepository.clearCachedUsers();

      emit(const AuthState.initial());
    } on Exception catch (_) {
      emit(const AuthState.initial());
    }
  }

  void resetState() {
    emit(const AuthState.initial());
  }
}
