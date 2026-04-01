import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Cargando
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Autenticado
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado: No autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado: Error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado: Email de recuperación enviado
class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
}

// Made with Bob
