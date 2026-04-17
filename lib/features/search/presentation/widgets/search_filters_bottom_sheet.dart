import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../promotions/domain/entities/category_entity.dart';
import '../../domain/entities/search_filters.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final List<CategoryEntity> categories;
  final void Function(SearchFilters filters) onApply;

  const SearchFiltersBottomSheet({
    super.key,
    required this.initialFilters,
    required this.categories,
    required this.onApply,
  });

  @override
  State<SearchFiltersBottomSheet> createState() =>
      _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late double _minDiscount;
  late List<String> _selectedCategoryIds;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  late double? _radiusKm;
  late SortBy _sortBy;

  @override
  void initState() {
    super.initState();
    _minDiscount = widget.initialFilters.minDiscount;
    _selectedCategoryIds = List.from(widget.initialFilters.categoryIds);
    _dateFrom = widget.initialFilters.dateFrom;
    _dateTo = widget.initialFilters.dateTo;
    _radiusKm = widget.initialFilters.radiusKm;
    _sortBy = widget.initialFilters.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Filtros avanzados',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Restablecer'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Descuento mínimo'),
                    const SizedBox(height: 8),
                    _buildDiscountSlider(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Categorías'),
                    const SizedBox(height: 8),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Rango de fechas'),
                    const SizedBox(height: 8),
                    _buildDateRange(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Radio de búsqueda'),
                    const SizedBox(height: 8),
                    _buildRadiusSlider(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Ordenar por'),
                    const SizedBox(height: 8),
                    _buildSortBy(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Apply button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aplicar filtros',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildDiscountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_minDiscount.toInt()}% o más',
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _minDiscount,
          min: 0,
          max: 90,
          divisions: 9,
          activeColor: AppColors.primary,
          label: '${_minDiscount.toInt()}%',
          onChanged: (v) => setState(() => _minDiscount = v),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    if (widget.categories.isEmpty) {
      return const Text('Sin categorías disponibles');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.categories.map((cat) {
        final selected = _selectedCategoryIds.contains(cat.id);
        return FilterChip(
          label: Text(cat.name),
          selected: selected,
          onSelected: (v) => setState(() {
            if (v) {
              _selectedCategoryIds.add(cat.id);
            } else {
              _selectedCategoryIds.remove(cat.id);
            }
          }),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateButton(
            label: _dateFrom != null
                ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                : 'Desde',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateFrom ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _dateFrom = picked);
            },
            onClear: _dateFrom != null
                ? () => setState(() => _dateFrom = null)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateButton(
            label: _dateTo != null
                ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                : 'Hasta',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateTo ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _dateTo = picked);
            },
            onClear:
                _dateTo != null ? () => setState(() => _dateTo = null) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _radiusKm != null ? '${_radiusKm!.toInt()} km' : 'Sin límite',
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _radiusKm ?? 0,
          min: 0,
          max: 20,
          divisions: 20,
          activeColor: AppColors.primary,
          label: _radiusKm != null ? '${_radiusKm!.toInt()} km' : 'Sin límite',
          onChanged: (v) => setState(() => _radiusKm = v == 0 ? null : v),
        ),
      ],
    );
  }

  Widget _buildSortBy() {
    return DropdownButtonFormField<SortBy>(
      initialValue: _sortBy,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: SortBy.relevance, child: Text('Relevancia')),
        DropdownMenuItem(
            value: SortBy.discount, child: Text('Mayor descuento')),
        DropdownMenuItem(value: SortBy.distance, child: Text('Más cercano')),
        DropdownMenuItem(value: SortBy.newest, child: Text('Más reciente')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _sortBy = v);
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _minDiscount = 0;
      _selectedCategoryIds = [];
      _dateFrom = null;
      _dateTo = null;
      _radiusKm = null;
      _sortBy = SortBy.relevance;
    });
  }

  void _applyFilters() {
    widget.onApply(
      SearchFilters(
        minDiscount: _minDiscount,
        categoryIds: _selectedCategoryIds,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        radiusKm: _radiusKm,
        sortBy: _sortBy,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateButton({
    required this.label,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.clear, size: 16),
            )
          else
            const Icon(Icons.calendar_today, size: 16),
        ],
      ),
    );
  }
}
