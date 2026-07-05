import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String label;
  final bool isSelfie;
  final Function(String?) onFileSelected;
  final String? initialValue;

  const DocumentUploadWidget({
    super.key,
    required this.label,
    required this.onFileSelected,
    this.isSelfie = false,
    this.initialValue,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _filePath;
  bool _isProcessing = false;
  double _uploadProgress = 0.0;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    _filePath = widget.initialValue;
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
      _uploadProgress = 0.0;
      _statusText = 'Accessing...';
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: widget.isSelfie ? CameraDevice.front : CameraDevice.rear,
      );

      if (file == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // Simulate Image Cropper
      setState(() => _statusText = widget.isSelfie ? 'Cropping to 1:1 circle...' : 'Cropping to 16:9...');
      await Future.delayed(const Duration(seconds: 1));

      // Simulate Upload Process
      setState(() => _statusText = 'Uploading document...');
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        setState(() {
          _uploadProgress = i / 10.0;
        });
      }

      setState(() {
        _filePath = file.path;
        _isProcessing = false;
        _uploadProgress = 1.0;
        _statusText = 'Upload complete ✓';
      });

      widget.onFileSelected(file.path);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusText = 'Error uploading';
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _filePath = null;
      _uploadProgress = 0.0;
      _statusText = null;
    });
    widget.onFileSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_filePath != null) ...[
            // Preview
            Row(
              children: [
                if (widget.isSelfie)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: ClipOval(
                      child: kIsWeb
                          ? Image.network(_filePath!, fit: BoxFit.cover)
                          : Image.file(File(_filePath!), fit: BoxFit.cover),
                    ),
                  )
                else
                  Container(
                    width: 110,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: kIsWeb
                          ? Image.network(_filePath!, fit: BoxFit.cover)
                          : Image.file(File(_filePath!), fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Complete',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _filePath!.split('/').last,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: _clearSelection,
                ),
              ],
            ),
          ] else if (_isProcessing) ...[
            // Progress indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _statusText ?? 'Uploading...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    minHeight: 6,
                    color: AppColors.accent,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Upload buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
