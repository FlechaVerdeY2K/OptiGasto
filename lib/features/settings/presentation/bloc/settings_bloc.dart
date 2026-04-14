import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../data/settings_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateSettings extends SettingsEvent {
  final AppSettingsEntity settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateSearchRadius extends SettingsEvent {
  final double radius;

  const UpdateSearchRadius(this.radius);

  @override
  List<Object?> get props => [radius];
}

class UpdateThemeMode extends SettingsEvent {
  final String mode;

  const UpdateThemeMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class UpdateInterestedCategories extends SettingsEvent {
  final List<String> categories;

  const UpdateInterestedCategories(this.categories);

  @override
  List<Object?> get props => [categories];
}

class ResetSettings extends SettingsEvent {
  const ResetSettings();
}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsUpdated extends SettingsState {
  final AppSettingsEntity settings;
  final String message;

  const SettingsUpdated(this.settings, this.message);

  @override
  List<Object?> get props => [settings, message];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;

  SettingsBloc(this._settingsService) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<UpdateSearchRadius>(_onUpdateSearchRadius);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateInterestedCategories>(_onUpdateInterestedCategories);
    on<ResetSettings>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());
      final settings = _settingsService.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Error al cargar configuraciones: $e'));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.saveSettings(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError('Error al guardar configuraciones: $e'));
    }
  }

  Future<void> _onUpdateSearchRadius(
    UpdateSearchRadius event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentSettings = (state as SettingsLoaded).settings;
        await _settingsService.updateSearchRadius(event.radius);
        final updatedSettings = currentSettings.copyWith(searchRadius: event.radius);
        emit(SettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(SettingsError('Error al actualizar radio de búsqueda: $e'));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentSettings = (state as SettingsLoaded).settings;
        await _settingsService.updateThemeMode(event.mode);
        final updatedSettings = currentSettings.copyWith(themeMode: event.mode);
        emit(SettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(SettingsError('Error al actualizar tema: $e'));
    }
  }

  Future<void> _onUpdateInterestedCategories(
    UpdateInterestedCategories event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentSettings = (state as SettingsLoaded).settings;
        await _settingsService.updateInterestedCategories(event.categories);
        final updatedSettings = currentSettings.copyWith(
          interestedCategories: event.categories,
        );
        emit(SettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(SettingsError('Error al actualizar categorías: $e'));
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.resetToDefaults();
      final settings = _settingsService.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Error al restablecer configuraciones: $e'));
    }
  }
}

// Made with Bob