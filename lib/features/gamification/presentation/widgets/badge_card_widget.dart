import 'package:flutter/material.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_badge_entity.dart';

/// Widget to display a single badge card
class BadgeCardWidget extends StatelessWidget {
  final BadgeEntity badge;
  final UserBadgeEntity? userBadge;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const BadgeCardWidget({
    super.key,
    required this.badge,
    this.userBadge,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      _getRarityColor(badge.rarity).withOpacity(0.1),
                      _getRarityColor(badge.rarity).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getRarityColor(badge.rarity).withOpacity(0.2)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge.icon,
                    style: TextStyle(
                      fontSize: 40,
                      color: isUnlocked ? null : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Badge name
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              // Badge description
              Text(
                badge.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 8),
              // Rarity badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getRarityColor(badge.rarity).withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRarityLabel(badge.rarity),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUnlocked
                            ? _getRarityColor(badge.rarity)
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
              ),
              // Unlock date (if unlocked)
              if (isUnlocked && userBadge != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Desbloqueada: ${_formatDate(userBadge!.unlockedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'COMÚN';
      case 'rare':
        return 'RARA';
      case 'epic':
        return 'ÉPICA';
      case 'legendary':
        return 'LEGENDARIA';
      default:
        return rarity.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Made with Bob
