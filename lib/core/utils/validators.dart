import '../constants/app_constants.dart';

/// Validadores para formularios
class Validators {
  Validators._();

  /// Valida email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }

    return null;
  }

  /// Valida contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede tener más de ${AppConstants.maxPasswordLength} caracteres';
    }

    return null;
  }

  /// Valida que las contraseñas coincidan
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Valida nombre
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (value.length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }

    return null;
  }

  /// Valida teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    final phoneRegex = RegExp(r'^\d{8}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Ingrese un número de teléfono válido (8 dígitos)';
    }

    return null;
  }

  /// Valida título de promoción
  static String? promotionTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'El título es requerido';
    }

    if (value.length < AppConstants.minPromotionTitleLength) {
      return 'El título debe tener al menos ${AppConstants.minPromotionTitleLength} caracteres';
    }

    if (value.length > AppConstants.maxPromotionTitleLength) {
      return 'El título no puede tener más de ${AppConstants.maxPromotionTitleLength} caracteres';
    }

    return null;
  }

  /// Valida descripción de promoción
  static String? promotionDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    if (value.length > AppConstants.maxPromotionDescriptionLength) {
      return 'La descripción no puede tener más de ${AppConstants.maxPromotionDescriptionLength} caracteres';
    }

    return null;
  }

  /// Valida precio
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    final priceValue = double.tryParse(value);

    if (priceValue == null) {
      return 'Ingrese un precio válido';
    }

    if (priceValue < 0) {
      return 'El precio no puede ser negativo';
    }

    if (priceValue > 10000000) {
      return 'El precio es demasiado alto';
    }

    return null;
  }

  /// Valida descuento
  static String? discount(String? value) {
    if (value == null || value.isEmpty) {
      return 'El descuento es requerido';
    }

    return null;
  }

  /// Valida campo requerido
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return '$fieldName no puede tener más de $max caracteres';
    }

    return null;
  }
}

// Made with Bob
