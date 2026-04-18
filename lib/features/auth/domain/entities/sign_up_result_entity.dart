import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// Resultado de registro con email.
///
/// Supabase puede crear el usuario sin devolver una sesión activa cuando la
/// confirmación de correo está habilitada.
class SignUpResultEntity extends Equatable {
  final UserEntity user;
  final bool requiresEmailConfirmation;

  const SignUpResultEntity({
    required this.user,
    required this.requiresEmailConfirmation,
  });

  @override
  List<Object?> get props => [user, requiresEmailConfirmation];
}
