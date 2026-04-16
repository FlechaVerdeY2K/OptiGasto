import 'dart:io';
import 'package:equatable/equatable.dart';

/// Eventos para el PublishPromotionBloc
abstract class PublishPromotionEvent extends Equatable {
  const PublishPromotionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para seleccionar imágenes
class SelectImagesEvent extends PublishPromotionEvent {
  final List<File> images;

  const SelectImagesEvent(this.images);

  @override
  List<Object?> get props => [images];
}

/// Evento para remover una imagen
class RemoveImageEvent extends PublishPromotionEvent {
  final int index;

  const RemoveImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Evento para seleccionar comercio
class SelectCommerceEvent extends PublishPromotionEvent {
  final String commerceId;
  final String commerceName;
  final double latitude;
  final double longitude;
  final String address;

  const SelectCommerceEvent({
    required this.commerceId,
    required this.commerceName,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props =>
      [commerceId, commerceName, latitude, longitude, address];
}

/// Evento para seleccionar categoría
class SelectCategoryEvent extends PublishPromotionEvent {
  final String category;

  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Evento para actualizar título
class UpdateTitleEvent extends PublishPromotionEvent {
  final String title;

  const UpdateTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

/// Evento para actualizar descripción
class UpdateDescriptionEvent extends PublishPromotionEvent {
  final String description;

  const UpdateDescriptionEvent(this.description);

  @override
  List<Object?> get props => [description];
}

/// Evento para actualizar descuento
class UpdateDiscountEvent extends PublishPromotionEvent {
  final String discount;

  const UpdateDiscountEvent(this.discount);

  @override
  List<Object?> get props => [discount];
}

/// Evento para actualizar precio original
class UpdateOriginalPriceEvent extends PublishPromotionEvent {
  final double? price;

  const UpdateOriginalPriceEvent(this.price);

  @override
  List<Object?> get props => [price];
}

/// Evento para actualizar precio con descuento
class UpdateDiscountedPriceEvent extends PublishPromotionEvent {
  final double? price;

  const UpdateDiscountedPriceEvent(this.price);

  @override
  List<Object?> get props => [price];
}

/// Evento para actualizar fecha de vencimiento
class UpdateValidUntilEvent extends PublishPromotionEvent {
  final DateTime validUntil;

  const UpdateValidUntilEvent(this.validUntil);

  @override
  List<Object?> get props => [validUntil];
}

/// Evento para publicar la promoción
class PublishPromotionSubmitEvent extends PublishPromotionEvent {
  const PublishPromotionSubmitEvent();
}

/// Evento para resetear el formulario
class ResetFormEvent extends PublishPromotionEvent {
  const ResetFormEvent();
}

// Made with Bob
