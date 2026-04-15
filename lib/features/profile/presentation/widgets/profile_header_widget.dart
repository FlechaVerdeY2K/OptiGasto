import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Widget del header del perfil con foto y datos básicos
class ProfileHeaderWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto de perfil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: user.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: onEditPressed,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nombre
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),

              if (user.phone != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.phone!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),

              // Botón de editar perfil
              OutlinedButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar Perfil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Badges y reputación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(
                    icon: Icons.star,
                    value: user.reputation.toString(),
                    label: 'Reputación',
                  ),
                  const SizedBox(width: 32),
                  _buildStatItem(
                    icon: Icons.emoji_events,
                    value: user.badges.length.toString(),
                    label: 'Insignias',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 60,
      color: AppColors.primary.withOpacity(0.5),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

// Made with Bob
