import 'package:flutter/material.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_badge_entity.dart';

/// Widget to showcase user's badges in profile
class BadgesShowcaseWidget extends StatelessWidget {
  final List<UserBadgeEntity> userBadges;
  final List<BadgeEntity> allBadges;
  final VoidCallback? onViewAll;

  const BadgesShowcaseWidget({
    super.key,
    required this.userBadges,
    required this.allBadges,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Get unlocked badge IDs
    // Get recent badges (last 3 unlocked)
    final recentBadges = userBadges.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insignias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userBadges.length} de ${allBadges.length} desbloqueadas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Ver todas'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Recent badges
            if (recentBadges.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no tienes insignias',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¡Completa acciones para desbloquearlas!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: recentBadges.map((userBadge) {
                  final badge = allBadges
                      .where((b) => b.id == userBadge.badgeId)
                      .firstOrNull;
                  if (badge == null) return const SizedBox.shrink();
                  return _buildBadgeItem(context, badge, true);
                }).toList(),
              ),
            const SizedBox(height: 16),
            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: userBadges.length / allBadges.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, BadgeEntity badge, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: unlocked
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              badge.icon,
              style: TextStyle(
                fontSize: 32,
                color: unlocked ? null : Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: unlocked ? null : Colors.grey[500],
                ),
          ),
        ),
      ],
    );
  }
}

// Made with Bob
