import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/user_model.dart';

/// Data source remoto para autenticación con Supabase
abstract class AuthRemoteDataSource {
  /// Obtiene el usuario actual de Supabase Auth
  Future<UserModel?> getCurrentUser();

  /// Inicia sesión con email y contraseña
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con email y contraseña
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Inicia sesión con Google
  Future<UserModel> signInWithGoogle();

  /// Inicia sesión con Apple
  Future<UserModel> signInWithApple();

  /// Cierra la sesión del usuario actual
  Future<void> signOut();

  /// Envía un email de recuperación de contraseña
  Future<void> sendPasswordResetEmail({required String email});

  /// Actualiza el perfil del usuario en Supabase
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? phone,
  });

  /// Stream que emite cambios en el estado de autenticación
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.supabase,
    required this.googleSignIn,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw ServerException(message: 'Error al iniciar sesión');
      }

      final userData = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userData);
    } on supabase_flutter.AuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.message));
    } catch (e) {
      throw ServerException(message: 'Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw ServerException(message: 'Error al crear usuario');
      }

      // Crear el registro del usuario en la tabla users
      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await supabase.from(SupabaseConfig.usersTable).insert(userModel.toJson());

      return userModel;
    } on AuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.message));
    } catch (e) {
      throw ServerException(message: 'Error al registrar usuario: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Intentar inicio de sesión silencioso primero (recomendado para web)
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

      // Si falla el inicio silencioso, usar el flujo interactivo
      googleUser ??= await googleSignIn.signIn();

      if (googleUser == null) {
        throw ServerException(message: 'Inicio de sesión cancelado');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw ServerException(message: 'Error al iniciar sesión con Google');
      }

      // Verificar si el usuario ya existe en la tabla users
      final existingUser = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (existingUser != null) {
        return UserModel.fromJson(existingUser);
      }

      // Crear nuevo usuario en la tabla users
      final userModel = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: (response.user!.userMetadata?['full_name'] as String?) ?? 'Usuario',
        photoUrl: response.user!.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.now(),
      );

      await supabase.from(SupabaseConfig.usersTable).insert(userModel.toJson());

      return userModel;
    } catch (e) {
      throw ServerException(message: 'Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Solicitar credenciales de Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Iniciar sesión en Supabase
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
      );

      if (response.user == null) {
        throw ServerException(message: 'Error al iniciar sesión con Apple');
      }

      // Verificar si el usuario ya existe en la tabla users
      final existingUser = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (existingUser != null) {
        return UserModel.fromJson(existingUser);
      }

      // Crear nuevo usuario en la tabla users
      String displayName = 'Usuario';
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
      } else if (response.user!.userMetadata?['full_name'] != null) {
        displayName = response.user!.userMetadata!['full_name'] as String;
      }

      final userModel = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? appleCredential.email ?? '',
        name: displayName,
        createdAt: DateTime.now(),
      );

      await supabase.from(SupabaseConfig.usersTable).insert(userModel.toJson());

      return userModel;
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          throw ServerException(message: 'Inicio de sesión cancelado');
        }
        throw ServerException(
            message: 'Error de autorización de Apple: ${e.message}');
      }
      throw ServerException(message: 'Error al iniciar sesión con Apple: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        supabase.auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.message));
    } catch (e) {
      throw ServerException(
        message: 'Error al enviar email de recuperación: $e',
      );
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (phone != null) updates['phone'] = phone;

      await supabase
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);

      final response = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar perfil: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

      try {
        final userData = await supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    });
  }

  /// Obtiene un mensaje de error amigable según el mensaje de error de Supabase
  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo electrónico o contraseña incorrectos';
    } else if (message.contains('User already registered')) {
      return 'Ya existe una cuenta con este correo electrónico';
    } else if (message.contains('Email not confirmed')) {
      return 'Por favor confirma tu correo electrónico';
    } else if (message.contains('Invalid email')) {
      return 'Correo electrónico inválido';
    } else if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (message.contains('User not found')) {
      return 'No existe una cuenta con este correo electrónico';
    } else if (message.contains('Too many requests')) {
      return 'Demasiados intentos. Intenta más tarde';
    }
    return 'Error de autenticación: $message';
  }
}

// Made with Bob
