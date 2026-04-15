import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterProfilePictureSection extends StatelessWidget {
  const RegisterProfilePictureSection({
    required this.isSubmitting,
    required this.onPickImage,
    required this.selectedProfileImage,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onPickImage;
  final XFile? selectedProfileImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: isSubmitting ? null : onPickImage,
          icon: const Icon(Icons.upload_rounded),
          label: Text(
            selectedProfileImage == null
                ? 'Upload from gallery'
                : 'Change picture',
          ),
        ),
        if (selectedProfileImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(selectedProfileImage!.path),
              height: 120,
              // For more performance, especially with large images, we can limit the cache size and dimensions.
              cacheWidth: 240, // Limit decoded image size for performance
              fit: BoxFit.cover,
              // Handle image loading errors gracefully
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: theme.colorScheme.errorContainer,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedProfileImage!.name,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
