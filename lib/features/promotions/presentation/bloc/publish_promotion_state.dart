import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/promotion_entity.dart';

/// Estados para el PublishPromotionBloc
abstract class PublishPromotionState extends Equatable {
  const PublishPromotionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PublishPromotionInitial extends PublishPromotionState {
  const PublishPromotionInitial();
}

/// Estado del formulario en edición
class PublishPromotionFormState extends PublishPromotionState {
  final List<XFile> selectedImages;
  final String? commerceId;
  final String? commerceName;
  final double? commerceLatitude;
  final double? commerceLongitude;
  final String? commerceAddress;
  final String? category;
  final String title;
  final String description;
  final String discount;
  final double? originalPrice;
  final double? discountedPrice;
  final DateTime? validUntil;
  final bool isValid;
  final String? errorMessage;

  const PublishPromotionFormState({
    this.selectedImages = const <XFile>[],
    this.commerceId,
    this.commerceName,
    this.commerceLatitude,
    this.commerceLongitude,
    this.commerceAddress,
    this.category,
    this.title = '',
    this.description = '',
    this.discount = '',
    this.originalPrice,
    this.discountedPrice,
    this.validUntil,
    this.isValid = false,
    this.errorMessage,
  });

  /// Copia el estado con campos actualizados
  PublishPromotionFormState copyWith({
    List<XFile>? selectedImages,
    String? commerceId,
    String? commerceName,
    double? commerceLatitude,
    double? commerceLongitude,
    String? commerceAddress,
    String? category,
    String? title,
    String? description,
    String? discount,
    double? originalPrice,
    double? discountedPrice,
    DateTime? validUntil,
    bool? isValid,
    String? errorMessage,
  }) {
    return PublishPromotionFormState(
      selectedImages: selectedImages ?? this.selectedImages,
      commerceId: commerceId ?? this.commerceId,
      commerceName: commerceName ?? this.commerceName,
      commerceLatitude: commerceLatitude ?? this.commerceLatitude,
      commerceLongitude: commerceLongitude ?? this.commerceLongitude,
      commerceAddress: commerceAddress ?? this.commerceAddress,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      validUntil: validUntil ?? this.validUntil,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedImages,
        commerceId,
        commerceName,
        commerceLatitude,
        commerceLongitude,
        commerceAddress,
        category,
        title,
        description,
        discount,
        originalPrice,
        discountedPrice,
        validUntil,
        isValid,
        errorMessage,
      ];
}

/// Estado de carga (subiendo imágenes o creando promoción)
class PublishPromotionLoading extends PublishPromotionState {
  final String message;
  final double? progress;

  const PublishPromotionLoading({
    this.message = 'Publicando promoción...',
    this.progress,
  });

  @override
  List<Object?> get props => [message, progress];
}

/// Estado de éxito
class PublishPromotionSuccess extends PublishPromotionState {
  final PromotionEntity promotion;
  final String message;

  const PublishPromotionSuccess({
    required this.promotion,
    this.message = 'Promoción publicada exitosamente',
  });

  @override
  List<Object?> get props => [promotion, message];
}

/// Estado de error
class PublishPromotionError extends PublishPromotionState {
  final String message;
  final PublishPromotionFormState? previousFormState;

  const PublishPromotionError({
    required this.message,
    this.previousFormState,
  });

  @override
  List<Object?> get props => [message, previousFormState];
}

// Made with Bob
