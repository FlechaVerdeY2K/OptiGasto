// lib/core/utils/duration_formatter.dart

/// Formatea segundos en texto legible. No requiere BuildContext.
class DurationFormatter {
  /// Convierte segundos a "1h 25min", "45min", o "< 1min".
  static String format(int totalSeconds) {
    if (totalSeconds <= 0) return '0min';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
    if (minutes > 0) return '${minutes}min';
    return '< 1min';
  }
}
