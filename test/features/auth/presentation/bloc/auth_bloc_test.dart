import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/features/auth/domain/entities/sign_up_result_entity.dart';
import 'package:optigasto/features/auth/domain/entities/user_entity.dart';
import 'package:optigasto/features/auth/domain/repositories/auth_repository.dart';
import 'package:optigasto/features/auth/domain/usecases/get_current_user.dart';
import 'package:optigasto/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:optigasto/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:optigasto/features/auth/domain/usecases/sign_out.dart';
import 'package:optigasto/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:optigasto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:optigasto/features/auth/presentation/bloc/auth_event.dart';
import 'package:optigasto/features/auth/presentation/bloc/auth_state.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSendPasswordResetEmail extends Mock
    implements SendPasswordResetEmail {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc bloc;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSendPasswordResetEmail mockSendPasswordResetEmail;
  late MockAuthRepository mockAuthRepository;

  final tUser = UserEntity(
    id: 'user-1',
    email: 'user@test.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockSendPasswordResetEmail = MockSendPasswordResetEmail();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream<UserEntity?>.empty());

    bloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
      sendPasswordResetEmail: mockSendPasswordResetEmail,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() => bloc.close());

  test(
    'AuthSignUpWithEmailRequested emits confirmation-required state '
    'when Supabase creates the account without an active session',
    () async {
      when(
        () => mockSignUpWithEmail(
          email: 'user@test.com',
          password: '123456',
          name: 'Test User',
        ),
      ).thenAnswer(
        (_) async => Right(
          SignUpResultEntity(
            user: tUser,
            requiresEmailConfirmation: true,
          ),
        ),
      );

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(
        const AuthSignUpWithEmailRequested(
          email: 'user@test.com',
          password: '123456',
          name: 'Test User',
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.first, isA<AuthLoading>());
      expect(states.last, isA<AuthRegistrationEmailConfirmationRequired>());
      final success = states.last as AuthRegistrationEmailConfirmationRequired;
      expect(success.email, 'user@test.com');
      expect(success.user, tUser);
    },
  );

  test(
    'AuthSignUpWithEmailRequested emits authenticated state '
    'when sign up returns an active session',
    () async {
      when(
        () => mockSignUpWithEmail(
          email: 'user@test.com',
          password: '123456',
          name: 'Test User',
        ),
      ).thenAnswer(
        (_) async => Right(
          SignUpResultEntity(
            user: tUser,
            requiresEmailConfirmation: false,
          ),
        ),
      );

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(
        const AuthSignUpWithEmailRequested(
          email: 'user@test.com',
          password: '123456',
          name: 'Test User',
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.first, isA<AuthLoading>());
      expect(states.last, isA<AuthAuthenticated>());
      final authenticated = states.last as AuthAuthenticated;
      expect(authenticated.user, tUser);
    },
  );
}
