import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/commerce_entity.dart';

/// Widget para buscar y seleccionar un comercio
class CommerceSearchWidget extends StatefulWidget {
  final String? selectedCommerceId;
  final String? selectedCommerceName;
  final void Function(String commerceId, String commerceName)
      onCommerceSelected;
  final Future<List<CommerceEntity>> Function(String query) onSearch;

  const CommerceSearchWidget({
    super.key,
    this.selectedCommerceId,
    this.selectedCommerceName,
    required this.onCommerceSelected,
    required this.onSearch,
  });

  @override
  State<CommerceSearchWidget> createState() => _CommerceSearchWidgetState();
}

class _CommerceSearchWidgetState extends State<CommerceSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<CommerceEntity> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final results = await widget.onSearch(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar comercios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectCommerce(CommerceEntity commerce) {
    widget.onCommerceSelected(commerce.id, commerce.name);
    _searchController.clear();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comercio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Comercio seleccionado o campo de búsqueda
        if (widget.selectedCommerceName != null)
          _SelectedCommerceCard(
            commerceName: widget.selectedCommerceName!,
            onClear: () {
              widget.onCommerceSelected('', '');
            },
          )
        else
          Column(
            children: [
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar comercio...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  _performSearch(value);
                },
              ),

              // Resultados de búsqueda
              if (_showResults)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _isSearching
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _searchResults.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No se encontraron comercios',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final commerce = _searchResults[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.store,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(commerce.name),
                                  subtitle: Text(
                                    commerce.type,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    commerce.address,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onTap: () => _selectCommerce(commerce),
                                );
                              },
                            ),
                ),
            ],
          ),

        if (widget.selectedCommerceName == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Busca y selecciona el comercio donde está la promoción',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
      ],
    );
  }
}

/// Card que muestra el comercio seleccionado
class _SelectedCommerceCard extends StatelessWidget {
  final String commerceName;
  final VoidCallback onClear;

  const _SelectedCommerceCard({
    required this.commerceName,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.store,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comercio seleccionado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  commerceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// Made with Bob
