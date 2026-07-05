import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);
const Color _error = Color(0xFFEF4444);

class QuestionWidget extends StatelessWidget {
  final FormFieldEntity field;
  final String value;
  final String? error;
  final bool hasFile;
  final String? fileName;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onPickFile;
  final VoidCallback? onRemoveFile;

  const QuestionWidget({
    super.key,
    required this.field,
    required this.value,
    this.error,
    this.hasFile = false,
    this.fileName,
    this.onChanged,
    this.onPickFile,
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildInput(context),
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: _error),
              const SizedBox(width: 4),
              Text(
                error!,
                style: const TextStyle(
                  fontSize: 12,
                  color: _error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        if (field.required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _error,
            ),
          ),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (field.type) {
      case 'textarea':
        return _buildTextArea();
      case 'number':
        return _buildTextField(keyboardType: TextInputType.number);
      case 'email':
        return _buildTextField(keyboardType: TextInputType.emailAddress);
      case 'phone':
        return _buildTextField(keyboardType: TextInputType.phone);
      case 'date':
        return _buildDatePicker(context);
      case 'select':
        return _buildDropdown();
      case 'file':
        return _buildFilePicker();
      default:
        return _buildTextField();
    }
  }

  Widget _buildTextField({TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error != null ? _error : _border,
          width: error != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: 1,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          hintText: field.placeholder,
          hintStyle: TextStyle(
            fontSize: 15,
            color: _textSecondary.withValues(alpha: 0.6),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error != null ? _error : _border,
          width: error != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        ),
        maxLines: 4,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          hintText: field.placeholder,
          hintStyle: TextStyle(
            fontSize: 15,
            color: _textSecondary.withValues(alpha: 0.6),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final displayText =
        value.isNotEmpty ? value : (field.placeholder ?? 'Select date');
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value.isNotEmpty
              ? DateTime.tryParse(value) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: _primary),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onChanged?.call(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null ? _error : _border,
            width: error != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 15,
                  color: value.isNotEmpty
                      ? _textPrimary
                      : _textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
            const Icon(Icons.calendar_today_rounded, size: 20, color: _primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error != null ? _error : _border,
          width: error != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isNotEmpty ? value : null,
          hint: Text(
            field.placeholder ?? 'Select an option',
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary.withValues(alpha: 0.6),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: _primary),
          items: (field.options ?? []).map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(fontSize: 15, color: _textPrimary),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged?.call(val);
          },
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return GestureDetector(
      onTap: hasFile ? null : onPickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null
                ? _error
                : hasFile
                    ? _primary
                    : _border,
            width: error != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasFile ? _bg : _border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                size: 22,
                color: hasFile ? _primary : _textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile
                        ? fileName ?? 'File selected'
                        : (field.placeholder ?? 'Tap to upload file'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          hasFile ? FontWeight.w600 : FontWeight.normal,
                      color: hasFile ? _textPrimary : _textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!hasFile)
                    Text(
                      'PDF, DOC, Images',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            if (hasFile)
              GestureDetector(
                onTap: onRemoveFile,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<MapEntry<String, String>?> pickFormFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'webp'],
  );

  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    if (file.path != null) {
      return MapEntry(file.path!, file.name);
    }
  }
  return null;
}
