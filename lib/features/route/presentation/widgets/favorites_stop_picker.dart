// lib/features/route/presentation/widgets/favorites_stop_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../../promotions/presentation/bloc/promotion_bloc.dart';
import '../../../promotions/presentation/bloc/promotion_event.dart';
import '../../../promotions/presentation/bloc/promotion_state.dart';
import '../../domain/entities/route_stop_entity.dart';

class FavoritesStopPicker extends StatefulWidget {
  final List<RouteStopEntity> selectedStops;
  final ValueChanged<List<RouteStopEntity>> onChanged;

  const FavoritesStopPicker({
    super.key,
    required this.selectedStops,
    required this.onChanged,
  });

  @override
  State<FavoritesStopPicker> createState() => _FavoritesStopPickerState();
}

class _FavoritesStopPickerState extends State<FavoritesStopPicker> {
  @override
  void initState() {
    super.initState();
    final promoState = context.read<PromotionBloc>().state;
    if (promoState is! PromotionLoaded) {
      context
          .read<PromotionBloc>()
          .add(const PromotionFetchRequested(limit: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final savedIds = authState is AuthAuthenticated
        ? authState.user.savedPromotions
        : <String>[];

    final promoState = context.watch<PromotionBloc>().state;

    if (promoState is PromotionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final PromotionLoaded? loaded =
        promoState is PromotionLoaded ? promoState : null;

    final favorites =
        loaded?.promotions.where((p) => savedIds.contains(p.id)).toList() ?? [];

    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No tenés favoritos guardados. Guardá algunas promociones primero.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final promo = favorites[index];
        final stop = RouteStopEntity(
          id: promo.id,
          promotionId: promo.id,
          name: promo.title,
          location: LocationEntity(
            latitude: promo.latitude,
            longitude: promo.longitude,
            timestamp: DateTime.now(),
          ),
          order: 0,
        );
        final isSelected = widget.selectedStops.any((s) => s.id == promo.id);

        return CheckboxListTile(
          title: Text(promo.title),
          subtitle: Text(promo.commerceName),
          value: isSelected,
          activeColor: AppColors.primary,
          onChanged: (checked) {
            final updated = List<RouteStopEntity>.from(widget.selectedStops);
            if (checked == true) {
              updated.add(stop);
            } else {
              updated.removeWhere((s) => s.id == promo.id);
            }
            widget.onChanged(updated);
          },
        );
      },
    );
  }
}
