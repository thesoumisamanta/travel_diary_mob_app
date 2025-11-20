import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String accountType;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.accountType,
  });

  @override
  List<Object?> get props => [username, email, password, fullName, accountType];
}

class AuthLogoutRequested extends AuthEvent {}