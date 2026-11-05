import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/letter_status.dart';

class KeyboardKey extends StatelessWidget {
  const KeyboardKey({
    super.key,
    required this.onTap,
    this.label,
    this.icon,
    this.status = LetterStatus.unknown,
    this.height = 54,
    this.semanticLabel,
  });

  final VoidCallback onTap;
  final String? label;
  final IconData? icon;
  final LetterStatus status;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final fg = colors.onColorFor(status);
    final radius = BorderRadius.circular(6);

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppConstants.keyColorDuration,
        curve: Curves.easeOut,
        height: height,
        decoration: BoxDecoration(color: colors.colorFor(status), borderRadius: radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: fg, size: 22)
                  : Text(
                      label!,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: label!.length > 1 ? 12 : 18,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
