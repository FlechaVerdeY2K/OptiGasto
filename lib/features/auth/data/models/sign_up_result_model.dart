import '../../domain/entities/sign_up_result_entity.dart';
import 'user_model.dart';

class SignUpResultModel extends SignUpResultEntity {
  const SignUpResultModel({
    required UserModel super.user,
    required super.requiresEmailConfirmation,
  });

  UserModel get userModel => user as UserModel;

  SignUpResultEntity toEntity() {
    return SignUpResultEntity(
      user: userModel.toEntity(),
      requiresEmailConfirmation: requiresEmailConfirmation,
    );
  }
}
