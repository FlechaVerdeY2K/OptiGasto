import 'package:flutter/material.dart';

/// Paleta de colores de OptiGasto
class AppColors {
  AppColors._();

  // Colores principales
  static const Color primary =
      Color(0xFF2E7D32); // Verde - ahorro, sostenibilidad
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  static const Color secondary =
      Color(0xFFFF6F00); // Naranja - promociones, urgencia
  static const Color secondaryLight = Color(0xFFFFA040);
  static const Color secondaryDark = Color(0xFFC43E00);

  static const Color accent = Color(0xFF0277BD); // Azul - confianza
  static const Color accentLight = Color(0xFF58A5F0);
  static const Color accentDark = Color(0xFF004C8C);

  // Colores de soporte
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutrales
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Bordes y divisores
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);

  // Sombras
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0A000000);

  // Overlay
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x33000000);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Colores específicos de la app
  static const Color promotionCard = surface;
  static const Color commerceCard = surface;
  static const Color mapMarker = primary;
  static const Color validationPositive = success;
  static const Color validationNegative = error;

  // Badges y gamificación
  static const Color badgeBronze = Color(0xFFCD7F32);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeGold = Color(0xFFFFD700);
  static const Color badgePlatinum = Color(0xFFE5E4E2);
}

// Made with Bob
