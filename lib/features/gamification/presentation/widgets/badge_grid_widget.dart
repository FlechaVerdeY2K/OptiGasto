import 'package:flutter/material.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_badge_entity.dart';
import 'badge_card_widget.dart';

/// Widget to display badges in a grid layout
class BadgeGridWidget extends StatelessWidget {
  final List<BadgeEntity> allBadges;
  final List<UserBadgeEntity> userBadges;
  final Function(BadgeEntity, bool)? onBadgeTap;
  final String? filterRarity;

  const BadgeGridWidget({
    super.key,
    required this.allBadges,
    required this.userBadges,
    this.onBadgeTap,
    this.filterRarity,
  });

  @override
  Widget build(BuildContext context) {
    // Get unlocked badge IDs
    final unlockedBadgeIds = userBadges.map((ub) => ub.badgeId).toSet();

    // Filter badges by rarity if specified
    final filteredBadges = filterRarity != null
        ? allBadges.where((b) => b.rarity.toLowerCase() == filterRarity!.toLowerCase()).toList()
        : allBadges;

    // Sort badges: unlocked first, then by rarity
    final sortedBadges = List<BadgeEntity>.from(filteredBadges)
      ..sort((a, b) {
        final aUnlocked = unlockedBadgeIds.contains(a.id);
        final bUnlocked = unlockedBadgeIds.contains(b.id);

        // Unlocked badges first
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;

        // Then by rarity
        return _getRarityOrder(b.rarity).compareTo(_getRarityOrder(a.rarity));
      });

    if (sortedBadges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay insignias disponibles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sortedBadges.length,
      itemBuilder: (context, index) {
        final badge = sortedBadges[index];
        final isUnlocked = unlockedBadgeIds.contains(badge.id);
        final userBadge = isUnlocked
            ? userBadges.firstWhere((ub) => ub.badgeId == badge.id)
            : null;

        return BadgeCardWidget(
          badge: badge,
          userBadge: userBadge,
          isUnlocked: isUnlocked,
          onTap: onBadgeTap != null
              ? () => onBadgeTap!(badge, isUnlocked)
              : null,
        );
      },
    );
  }

  int _getRarityOrder(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 4;
      case 'epic':
        return 3;
      case 'rare':
        return 2;
      case 'common':
        return 1;
      default:
        return 0;
    }
  }
}

// Made with Bob
