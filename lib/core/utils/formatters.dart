import 'package:intl/intl.dart';

/// Formateadores de datos
class Formatters {
  Formatters._();

  /// Formatea precio en colones costarricenses
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CR',
      symbol: '₡',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formatea precio con decimales
  static String currencyWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CR',
      symbol: '₡',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formatea distancia
  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Formatea fecha
  static String date(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'es_CR');
    return formatter.format(date);
  }

  /// Formatea fecha y hora
  static String dateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'es_CR');
    return formatter.format(dateTime);
  }

  /// Formatea hora
  static String time(DateTime time) {
    final formatter = DateFormat('HH:mm', 'es_CR');
    return formatter.format(time);
  }

  /// Formatea fecha relativa (hace X tiempo)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }

  /// Formatea número con separadores de miles
  static String number(int number) {
    final formatter = NumberFormat('#,###', 'es_CR');
    return formatter.format(number);
  }

  /// Formatea porcentaje
  static String percentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  /// Formatea teléfono
  static String phone(String phone) {
    // Formato: 8888-8888
    if (phone.length == 8) {
      return '${phone.substring(0, 4)}-${phone.substring(4)}';
    }
    return phone;
  }

  /// Capitaliza primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Trunca texto
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// Formatea duración
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  /// Formatea tamaño de archivo
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Alias para currency (compatibilidad)
  static String formatCurrency(double amount) => currency(amount);

  /// Alias para date (compatibilidad)
  static String formatDate(DateTime date) => Formatters.date(date);
}

// Made with Bob
