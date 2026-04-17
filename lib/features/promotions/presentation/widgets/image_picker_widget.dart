import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget para seleccionar y mostrar imágenes de promociones
class ImagePickerWidget extends StatelessWidget {
  final List<File> selectedImages;
  final void Function(List<File>) onImagesSelected;
  final void Function(int) onImageRemoved;
  final int maxImages;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
    required this.onImageRemoved,
    this.maxImages = 5,
  });

  Future<void> _pickImages(BuildContext context) async {
    if (selectedImages.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Máximo $maxImages imágenes permitidas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();

    // Mostrar opciones: cámara o galería
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        // Selección múltiple de galería
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (images.isNotEmpty) {
          final files = await Future.wait(
            images.asMap().entries.map((e) => _xFileToTempFile(e.value, e.key)),
          );
          onImagesSelected(files);
        }
      } else {
        // Tomar foto con cámara
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          final file = await _xFileToTempFile(image, 0);
          onImagesSelected([file]);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imágenes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Copies XFile to a temp directory so dart:io can read it (Android content:// URIs)
  Future<File> _xFileToTempFile(XFile xFile, int index) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final ext = xFile.path.contains('.') ? xFile.path.split('.').last : 'jpg';
      final tmpPath =
          '${tmpDir.path}/pick_${DateTime.now().millisecondsSinceEpoch}_$index.$ext';
      final bytes = await xFile.readAsBytes();
      return await File(tmpPath).writeAsBytes(bytes);
    } catch (_) {
      return File(xFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos de la promoción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${selectedImages.length}/$maxImages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == selectedImages.length) {
                // Botón para agregar más imágenes
                return _AddImageButton(
                  onTap: () => _pickImages(context),
                  isDisabled: selectedImages.length >= maxImages,
                );
              }

              // Mostrar imagen seleccionada
              return _ImagePreview(
                image: selectedImages[index],
                onRemove: () => onImageRemoved(index),
              );
            },
          ),
        ),
        if (selectedImages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Agrega al menos una foto de la promoción',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
      ],
    );
  }
}

/// Botón para agregar imágenes
class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDisabled;

  const _AddImageButton({
    required this.onTap,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[300]
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey : AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: isDisabled ? Colors.grey : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: TextStyle(
                color: isDisabled ? Colors.grey : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista previa de imagen seleccionada
class _ImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      // XFile.readAsBytes() handles content:// URIs and real paths on all platforms
      future: XFile(image.path).readAsBytes(),
      builder: (context, snapshot) {
        final Widget imageWidget = snapshot.hasData
            ? Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: MemoryImage(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: snapshot.hasError
                    ? const Icon(Icons.broken_image, color: Colors.grey)
                    : const Center(child: CircularProgressIndicator()),
              );

        return Stack(
          children: [
            imageWidget,
            Positioned(
              top: 4,
              right: 16,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Made with Bob
