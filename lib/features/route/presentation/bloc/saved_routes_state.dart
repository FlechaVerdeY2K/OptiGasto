import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_route_entity.dart';

abstract class SavedRoutesState extends Equatable {
  const SavedRoutesState();

  @override
  List<Object?> get props => [];
}

class SavedRoutesInitial extends SavedRoutesState {
  const SavedRoutesInitial();
}

class SavedRoutesLoading extends SavedRoutesState {
  const SavedRoutesLoading();
}

class SavedRoutesLoaded extends SavedRoutesState {
  final List<SavedRouteEntity> routes;

  const SavedRoutesLoaded({required this.routes});

  @override
  List<Object?> get props => [routes];
}

class SavedRouteOperationInProgress extends SavedRoutesState {
  const SavedRouteOperationInProgress();
}

class SavedRoutesError extends SavedRoutesState {
  final String message;

  const SavedRoutesError({required this.message});

  @override
  List<Object?> get props => [message];
}
