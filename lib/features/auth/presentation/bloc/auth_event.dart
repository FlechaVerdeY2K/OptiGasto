import 'package:equatable/equatable.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Verificar estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento: Iniciar sesión con email
class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento: Registrarse con email
class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Evento: Iniciar sesión con Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Evento: Iniciar sesión con Apple
class AuthSignInWithAppleRequested extends AuthEvent {
  const AuthSignInWithAppleRequested();
}

/// Evento: Cerrar sesión
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Evento: Enviar email de recuperación
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Evento: Cambio en el estado de autenticación (desde stream)
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

// Made with Bob
