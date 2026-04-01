import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Data source remoto para autenticación con Firebase
abstract class AuthRemoteDataSource {
  /// Obtiene el usuario actual de Firebase Auth
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

  /// Actualiza el perfil del usuario en Firestore
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
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
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
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException(message: 'Error al iniciar sesión');
      }

      final doc = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw ServerException(message: 'Usuario no encontrado en Firestore');
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.code));
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
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException(message: 'Error al crear usuario');
      }

      // Crear documento de usuario en Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error al registrar usuario: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw ServerException(message: 'Inicio de sesión cancelado');
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = 
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw ServerException(message: 'Error al iniciar sesión con Google');
      }

      // Verificar si el usuario ya existe en Firestore
      final doc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Crear nuevo usuario en Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? 'Usuario',
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

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

      // Crear credencial de Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Iniciar sesión en Firebase
      final userCredential =
          await firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw ServerException(message: 'Error al iniciar sesión con Apple');
      }

      // Verificar si el usuario ya existe en Firestore
      final doc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Crear nuevo usuario en Firestore
      // Apple puede no proporcionar el nombre en intentos posteriores
      String displayName = 'Usuario';
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
      } else if (userCredential.user!.displayName != null) {
        displayName = userCredential.user!.displayName!;
      }

      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? appleCredential.email ?? '',
        name: displayName,
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

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
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e.code));
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
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (phone != null) updates['phone'] = phone;

      await firestore.collection('users').doc(userId).update(updates);

      final doc = await firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar perfil: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      try {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      } catch (e) {
        return null;
      }
    });
  }

  /// Obtiene un mensaje de error amigable según el código de error de Firebase
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: $code';
    }
  }
}

// Made with Bob
