import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/optimized_route_entity.dart';
import '../../domain/usecases/build_navigation_url.dart';

class ExportRouteButtons extends StatelessWidget {
  final OptimizedRouteEntity route;

  const ExportRouteButtons({super.key, required this.route});

  Future<void> _launch(BuildContext context, NavigationApp app) async {
    final useCase = sl<BuildNavigationUrl>();
    final result = useCase(app: app, route: route);

    await result.fold(
      (failure) async {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (url) async {
        try {
          final uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Esta app no está instalada en tu dispositivo.')),
              );
            }
          }
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Esta app no está instalada en tu dispositivo.')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _launch(context, NavigationApp.googleMaps),
          icon: const Icon(Icons.map),
          label: const Text('Abrir en Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 8),
        Tooltip(
          message: 'Waze solo navega al primer destino de la ruta',
          child: OutlinedButton.icon(
            onPressed: () => _launch(context, NavigationApp.waze),
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Abrir en Waze'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }
}
