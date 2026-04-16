import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/usecases/create_promotion.dart';
import '../../domain/usecases/upload_promotion_images.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import 'publish_promotion_event.dart';
import 'publish_promotion_state.dart';

/// BLoC para gestionar la publicación de promociones
class PublishPromotionBloc
    extends Bloc<PublishPromotionEvent, PublishPromotionState> {
  final CreatePromotion createPromotion;
  final UploadPromotionImages uploadPromotionImages;
  final GetCurrentUser getCurrentUser;

  PublishPromotionBloc({
    required this.createPromotion,
    required this.uploadPromotionImages,
    required this.getCurrentUser,
  }) : super(const PublishPromotionInitial()) {
    on<SelectImagesEvent>(_onSelectImages);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SelectCommerceEvent>(_onSelectCommerce);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<UpdateTitleEvent>(_onUpdateTitle);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateDiscountEvent>(_onUpdateDiscount);
    on<UpdateOriginalPriceEvent>(_onUpdateOriginalPrice);
    on<UpdateDiscountedPriceEvent>(_onUpdateDiscountedPrice);
    on<UpdateValidUntilEvent>(_onUpdateValidUntil);
    on<PublishPromotionSubmitEvent>(_onPublishPromotion);
    on<ResetFormEvent>(_onResetForm);
  }

  PublishPromotionFormState _getCurrentFormState() {
    if (state is PublishPromotionFormState) {
      return state as PublishPromotionFormState;
    }
    return const PublishPromotionFormState();
  }

  bool _validateForm(PublishPromotionFormState formState) {
    return formState.selectedImages.isNotEmpty &&
        formState.commerceId != null &&
        formState.commerceId!.isNotEmpty &&
        formState.commerceLatitude != null &&
        formState.commerceLongitude != null &&
        formState.category != null &&
        formState.title.trim().isNotEmpty &&
        formState.description.trim().isNotEmpty &&
        formState.discount.trim().isNotEmpty &&
        formState.validUntil != null;
  }

  void _onSelectImages(
    SelectImagesEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final updatedImages = List<File>.from(currentState.selectedImages)
      ..addAll(event.images);

    if (updatedImages.length > 5) {
      emit(currentState.copyWith(
        errorMessage: 'Máximo 5 imágenes permitidas',
      ));
      return;
    }

    final newState = currentState.copyWith(
      selectedImages: updatedImages,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final updatedImages = List<File>.from(currentState.selectedImages)
      ..removeAt(event.index);

    final newState = currentState.copyWith(
      selectedImages: updatedImages,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onSelectCommerce(
    SelectCommerceEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      commerceId: event.commerceId,
      commerceName: event.commerceName,
      commerceLatitude: event.latitude,
      commerceLongitude: event.longitude,
      commerceAddress: event.address,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      category: event.category,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateTitle(
    UpdateTitleEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      title: event.title,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      description: event.description,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateDiscount(
    UpdateDiscountEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      discount: event.discount,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateOriginalPrice(
    UpdateOriginalPriceEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      originalPrice: event.price,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateDiscountedPrice(
    UpdateDiscountedPriceEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      discountedPrice: event.price,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  void _onUpdateValidUntil(
    UpdateValidUntilEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    final currentState = _getCurrentFormState();
    final newState = currentState.copyWith(
      validUntil: event.validUntil,
      errorMessage: null,
    );
    emit(newState.copyWith(isValid: _validateForm(newState)));
  }

  Future<void> _onPublishPromotion(
    PublishPromotionSubmitEvent event,
    Emitter<PublishPromotionState> emit,
  ) async {
    final formState = _getCurrentFormState();

    if (!_validateForm(formState)) {
      emit(PublishPromotionError(
        message: 'Por favor completa todos los campos requeridos',
        previousFormState: formState,
      ));
      return;
    }

    emit(const PublishPromotionLoading(message: 'Obteniendo usuario...'));

    final userResult = await getCurrentUser();
    if (userResult.isLeft()) {
      emit(PublishPromotionError(
        message: 'Error al obtener usuario actual',
        previousFormState: formState,
      ));
      return;
    }

    final user = userResult.getOrElse(() => throw Exception('No user'));

    emit(const PublishPromotionLoading(
      message: 'Subiendo imágenes...',
      progress: 0.3,
    ));

    final promotionId = const Uuid().v4();

    final uploadResult = await uploadPromotionImages(
      images: formState.selectedImages,
      promotionId: promotionId,
    );

    if (uploadResult.isLeft()) {
      emit(PublishPromotionError(
        message: 'Error al subir imágenes',
        previousFormState: formState,
      ));
      return;
    }

    final imageUrls = uploadResult.getOrElse(() => []);

    emit(const PublishPromotionLoading(
      message: 'Creando promoción...',
      progress: 0.7,
    ));

    final now = DateTime.now();
    final promotion = PromotionEntity(
      id: promotionId,
      title: formState.title.trim(),
      description: formState.description.trim(),
      commerceId: formState.commerceId!,
      commerceName: formState.commerceName!,
      category: formState.category!,
      discount: formState.discount.trim(),
      originalPrice: formState.originalPrice,
      discountedPrice: formState.discountedPrice,
      images: imageUrls,
      latitude: formState.commerceLatitude!,
      longitude: formState.commerceLongitude!,
      address: formState.commerceAddress!,
      validUntil: formState.validUntil!,
      createdBy: user!.id,
      createdAt: now,
      updatedAt: now,
    );

    final createResult = await createPromotion(promotion: promotion);

    createResult.fold(
      (failure) => emit(PublishPromotionError(
        message: failure.message,
        previousFormState: formState,
      )),
      (createdPromotion) => emit(PublishPromotionSuccess(
        promotion: createdPromotion,
        message: '¡Promoción publicada exitosamente!',
      )),
    );
  }

  void _onResetForm(
    ResetFormEvent event,
    Emitter<PublishPromotionState> emit,
  ) {
    emit(const PublishPromotionFormState());
  }
}

// Made with Bob
