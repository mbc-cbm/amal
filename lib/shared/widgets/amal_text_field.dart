import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class AmalTextField extends StatefulWidget {
  const AmalTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.autofillHints,
    this.prefixIcon,
    this.enabled = true,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final bool enabled;
  final bool autofocus;

  @override
  State<AmalTextField> createState() => _AmalTextFieldState();
}

class _AmalTextFieldState extends State<AmalTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      style: AppTypography.bodyLarge.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
    );
  }
}
