// lib/features/route/presentation/widgets/stop_selection_method_picker.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/route_planner_event.dart';

class StopSelectionMethodPicker extends StatelessWidget {
  final StopSelectionMethod selected;
  final ValueChanged<StopSelectionMethod> onChanged;

  const StopSelectionMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: StopSelectionMethod.values.map((method) {
        final isSelected = method == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_label(method)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) => onChanged(method),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(StopSelectionMethod method) => switch (method) {
        StopSelectionMethod.map => 'En el mapa',
        StopSelectionMethod.favorites => 'Mis favoritos',
        StopSelectionMethod.nearby => 'Cercanas a mí',
      };
}
