import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Página de historial completo de promociones usadas
class PromotionHistoryPage extends StatelessWidget {
  const PromotionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Completo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todo')),
                      DropdownMenuItem(value: 'month', child: Text('Este mes')),
                      DropdownMenuItem(
                          value: 'week', child: Text('Esta semana')),
                    ],
                    onChanged: (value) {
                      // TODO: Filtrar por período
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todas')),
                      DropdownMenuItem(value: 'food', child: Text('Comida')),
                      DropdownMenuItem(
                          value: 'tech', child: Text('Tecnología')),
                    ],
                    onChanged: (value) {
                      // TODO: Filtrar por categoría
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de historial
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Mensaje cuando no hay datos
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin historial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no has usado ninguna promoción',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ejemplo de items de historial (comentado)
                // _HistoryItem(
                //   title: '50% OFF en Pizzas',
                //   commerce: 'Pizza Hut',
                //   date: DateTime.now(),
                //   savings: 5000,
                //   category: 'Restaurantes',
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
