import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchSuggestionsList extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final void Function(String suggestion) onTap;

  const SearchSuggestionsList({
    super.key,
    required this.suggestions,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          'Sin sugerencias para "$query"',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search, size: 20),
          title: Text(suggestion),
          trailing: const Icon(Icons.north_west, size: 16),
          onTap: () => onTap(suggestion),
          dense: true,
        );
      },
    );
  }
}
