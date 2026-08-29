import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/theme/app_colors.dart';

class GoldenTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const GoldenTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  State<GoldenTextField> createState() => _GoldenTextFieldState();
}

class _GoldenTextFieldState extends State<GoldenTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.hintText ?? widget.hint ?? '';
    final effectiveIcon = widget.prefixIcon ?? Icons.edit_note_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: GoogleFonts.outfit(
              color: AppColors.lightGold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.cardSurface,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
            cursorColor: AppColors.lightGold,
            decoration: InputDecoration(
              hintText: effectiveHint,
              hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
              prefixIcon: Icon(
                effectiveIcon,
                color: AppColors.primaryGold,
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
