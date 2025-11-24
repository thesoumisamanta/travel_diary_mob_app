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
      // If we can't get profile but have token, still consider authenticated
      // The profile will be loaded separately
      final hasToken = await storageRepository.getAccessToken() != null;
      if (hasToken) {
        try {
          final user = await authRepository.getUserProfile();
          emit(AuthAuthenticated(user));
        } catch (_) {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Save remember me preferences BEFORE login attempt
      await storageRepository.saveRememberMe(event.rememberMe);

      if (event.rememberMe) {
        await storageRepository.saveUserEmail(event.identifier);
        await storageRepository.saveUserPassword(event.password);
      } else {
        await storageRepository.clearRememberMeData();
      }

      // Attempt login
      final user = await authRepository.login(event.identifier, event.password);

      // Important: Emit AuthAuthenticated AFTER successful login
      emit(AuthAuthenticated(user));
    } catch (e) {
      // On login failure, clear remember me data for security
      await storageRepository.clearRememberMeData();
      
      // Emit error first
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      
      // Then emit unauthenticated - use a small delay to ensure error is processed
      await Future.delayed(const Duration(milliseconds: 100));
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
        'fullName': event.fullName,
        'accountType': event.accountType,
      });
      
      // Check if user has tokens (by checking if they're stored)
      final hasTokens = await authRepository.isAuthenticated();
      
      if (hasTokens) {
        // User registered and got tokens, navigate to home
        emit(AuthAuthenticated(user));
      } else {
        // Registration succeeded but no tokens were provided
        // User needs to login
        emit(AuthRegistrationSuccess(user: user, hasTokens: false));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      await Future.delayed(const Duration(milliseconds: 100));
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
    } catch (e) {
      // Ignore API error and proceed with local logout
    } finally {
      emit(AuthUnauthenticated());
    }
  }
}