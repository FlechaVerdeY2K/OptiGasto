import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/saved_routes_repository.dart';
import '../../data/models/saved_route_model.dart';
import 'saved_routes_event.dart';
import 'saved_routes_state.dart';

class SavedRoutesBloc extends Bloc<SavedRoutesEvent, SavedRoutesState> {
  final SavedRoutesRepository _repository;

  SavedRoutesBloc({required SavedRoutesRepository repository})
      : _repository = repository,
        super(const SavedRoutesInitial()) {
    on<SavedRoutesLoadRequested>(_onLoad);
    on<SavedRouteCreateRequested>(_onCreate);
    on<SavedRouteUpdateRequested>(_onUpdate);
    on<SavedRouteDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    SavedRoutesLoadRequested event,
    Emitter<SavedRoutesState> emit,
  ) async {
    emit(const SavedRoutesLoading());
    final result = await _repository.getSavedRoutes();
    result.fold(
      (failure) => emit(SavedRoutesError(message: failure.message)),
      (routes) => emit(SavedRoutesLoaded(routes: routes)),
    );
  }

  Future<void> _onCreate(
    SavedRouteCreateRequested event,
    Emitter<SavedRoutesState> emit,
  ) async {
    emit(const SavedRouteOperationInProgress());
    final newRoute = SavedRouteModel(
      id: '',
      userId: '',
      name: event.name,
      origin: event.route.origin,
      stops: event.route.stops,
      distanceMeters: event.route.totalDistanceMeters,
      durationSeconds: event.route.totalDurationSeconds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await _repository.createSavedRoute(newRoute);
    await result.fold(
      (failure) async => emit(SavedRoutesError(message: failure.message)),
      (_) async => _reloadList(emit),
    );
  }

  Future<void> _onUpdate(
    SavedRouteUpdateRequested event,
    Emitter<SavedRoutesState> emit,
  ) async {
    emit(const SavedRouteOperationInProgress());
    final result = await _repository.updateSavedRoute(event.route);
    await result.fold(
      (failure) async => emit(SavedRoutesError(message: failure.message)),
      (_) async => _reloadList(emit),
    );
  }

  Future<void> _onDelete(
    SavedRouteDeleteRequested event,
    Emitter<SavedRoutesState> emit,
  ) async {
    emit(const SavedRouteOperationInProgress());
    final result = await _repository.deleteSavedRoute(event.routeId);
    await result.fold(
      (failure) async => emit(SavedRoutesError(message: failure.message)),
      (_) async => _reloadList(emit),
    );
  }

  Future<void> _reloadList(Emitter<SavedRoutesState> emit) async {
    final result = await _repository.getSavedRoutes();
    result.fold(
      (failure) => emit(SavedRoutesError(message: failure.message)),
      (routes) => emit(SavedRoutesLoaded(routes: routes)),
    );
  }
}
