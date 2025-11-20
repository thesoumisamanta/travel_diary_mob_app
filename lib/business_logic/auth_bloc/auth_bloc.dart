import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/storage_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final StorageRepository storageRepository;

  AuthBloc({required this.authRepository, required this.storageRepository})
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final authenticated = await authRepository.isAuthenticated();

      if (!authenticated) {
        emit(AuthUnauthenticated());
        return;
      }

      final user = await authRepository.getUserProfile();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // First, save remember me preferences BEFORE login attempt
      await storageRepository.saveRememberMe(event.rememberMe);

      if (event.rememberMe) {
        // Save credentials if remember me is checked
        await storageRepository.saveUserEmail(event.identifier);
        await storageRepository.saveUserPassword(event.password);
      } else {
        // Clear saved credentials if remember me is unchecked
        await storageRepository.clearRememberMeData();
      }

      // Attempt login
      final user = await authRepository.login(event.identifier, event.password);

      emit(AuthAuthenticated(user));
    } catch (e) {
      // On login failure, clear remember me data for security
      await storageRepository.clearRememberMeData();
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register({
        'username': event.username,
        'email': event.email,
        'password': event.password,
        'full_name': event.fullName,
        'account_type': event.accountType,
      });
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }
}