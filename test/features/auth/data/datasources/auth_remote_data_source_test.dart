import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/exceptions.dart';
import 'package:optigasto/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockGoogleSignIn = MockGoogleSignIn();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    dataSource = AuthRemoteDataSourceImpl(
      supabase: mockSupabaseClient,
      googleSignIn: mockGoogleSignIn,
    );
  });

  test(
    'signUpWithEmail maps Email Rate Limit Exceeded to a friendly message',
    () async {
      when(
        () => mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: '123456',
          data: {'name': 'Test User'},
        ),
      ).thenThrow(const AuthException('Email Rate Limit Exceeded'));

      expect(
        () => dataSource.signUpWithEmail(
          email: 'test@example.com',
          password: '123456',
          name: 'Test User',
        ),
        throwsA(
          isA<ServerException>().having(
            (exception) => exception.message,
            'message',
            'Has alcanzado el límite de correos. Espera un momento e intenta de nuevo.',
          ),
        ),
      );
    },
  );
}
