import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../bloc/publish_promotion_bloc.dart';
import '../bloc/publish_promotion_event.dart';
import '../bloc/publish_promotion_state.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/commerce_search_widget.dart';

/// Página para publicar una nueva promoción
class PublishPromotionPage extends StatelessWidget {
  const PublishPromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PublishPromotionBloc>(),
      child: const _PublishPromotionView(),
    );
  }
}

class _PublishPromotionView extends StatefulWidget {
  const _PublishPromotionView();

  @override
  State<_PublishPromotionView> createState() => _PublishPromotionViewState();
}

class _PublishPromotionViewState extends State<_PublishPromotionView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  late final ConfettiController _confettiController;

  final List<String> _categories = [
    'Alimentos y Bebidas',
    'Electrónica',
    'Ropa',
    'Hogar',
    'Salud',
    'Deportes',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 7));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: AppColors.primary)
                : const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      context.read<PublishPromotionBloc>().add(UpdateValidUntilEvent(date));
    }
  }

  void _handlePublish(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<PublishPromotionBloc>()
          .add(const PublishPromotionSubmitEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Publicar Promoción'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: BlocConsumer<PublishPromotionBloc, PublishPromotionState>(
            listener: (context, state) {
              if (state is PublishPromotionSuccess) {
                _confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                // Delay pop so confetti is visible
                Future.delayed(const Duration(seconds: 3), () {
                  if (context.mounted) context.pop(true);
                });
              } else if (state is PublishPromotionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PublishPromotionLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(state.message),
                      if (state.progress != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LinearProgressIndicator(
                            value: state.progress,
                          ),
                        ),
                    ],
                  ),
                );
              }

              final formState = state is PublishPromotionFormState
                  ? state
                  : const PublishPromotionFormState();

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Selector de imágenes
                    ImagePickerWidget(
                      selectedImages: formState.selectedImages,
                      onImagesSelected: (images) {
                        context.read<PublishPromotionBloc>().add(
                              SelectImagesEvent(images),
                            );
                      },
                      onImageRemoved: (index) {
                        context.read<PublishPromotionBloc>().add(
                              RemoveImageEvent(index),
                            );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Selector de comercio
                    CommerceSearchWidget(
                      selectedCommerceId: formState.commerceId,
                      selectedCommerceName: formState.commerceName,
                      onCommerceSelected: (id, name, lat, lng, address) {
                        context.read<PublishPromotionBloc>().add(
                              SelectCommerceEvent(
                                commerceId: id,
                                commerceName: name,
                                latitude: lat,
                                longitude: lng,
                                address: address,
                              ),
                            );
                      },
                      onSearch: (query) async {
                        final repository = sl<PromotionRepository>();
                        final result = await repository.searchCommerces(
                          query: query,
                          limit: 10,
                        );
                        return result.fold(
                          (failure) => [],
                          (commerces) => commerces,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Selector de categoría
                    _buildCategorySelector(context, formState),
                    const SizedBox(height: 24),

                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de la promoción *',
                        hintText: 'Ej: 2x1 en pizzas grandes',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<PublishPromotionBloc>().add(
                              UpdateTitleEvent(value),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Describe los detalles de la promoción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<PublishPromotionBloc>().add(
                              UpdateDescriptionEvent(value),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descuento
                    TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Descuento *',
                        hintText: 'Ej: 50%, 2x1, ₡5000 de descuento',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El descuento es requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<PublishPromotionBloc>().add(
                              UpdateDiscountEvent(value),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Precios (opcionales)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _originalPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio original',
                              hintText: '₡10000',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final price = double.tryParse(value);
                              context.read<PublishPromotionBloc>().add(
                                    UpdateOriginalPriceEvent(price),
                                  );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _discountedPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio con descuento',
                              hintText: '₡5000',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final price = double.tryParse(value);
                              context.read<PublishPromotionBloc>().add(
                                    UpdateDiscountedPriceEvent(price),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fecha de vencimiento
                    _buildDateSelector(context, formState),
                    const SizedBox(height: 32),

                    // Botón de publicar
                    ElevatedButton(
                      onPressed: formState.isValid
                          ? () => _handlePublish(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Publicar Promoción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
        // Confetti overlay — plays on PublishPromotionSuccess
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            createParticlePath: (size) {
              final path = Path();
              path.addOval(Rect.fromCircle(
                center: Offset.zero,
                radius: size.width / 2,
              ));
              return path;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    PublishPromotionFormState formState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = formState.category == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<PublishPromotionBloc>().add(
                        SelectCategoryEvent(category),
                      );
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    PublishPromotionFormState formState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Válido hasta *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  formState.validUntil != null
                      ? '${formState.validUntil!.day}/${formState.validUntil!.month}/${formState.validUntil!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: formState.validUntil != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Made with Bob
