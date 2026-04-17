import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_history_item.dart';

class SearchHistoryList extends StatelessWidget {
  final List<SearchHistoryItem> history;
  final void Function(String query) onTap;
  final VoidCallback onClearAll;

  const SearchHistoryList({
    super.key,
    required this.history,
    required this.onTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Sin búsquedas recientes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Text(
                'Búsquedas recientes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: const Text('Borrar todo'),
              ),
            ],
          ),
        ),
        ...history.map(
          (item) => ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(item.query),
            trailing: const Icon(Icons.north_west, size: 16),
            onTap: () => onTap(item.query),
            dense: true,
          ),
        ),
      ],
    );
  }
}
