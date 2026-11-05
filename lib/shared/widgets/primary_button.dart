import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.outlined = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final text = Text(label.toUpperCase());
    if (outlined) {
      return icon == null
          ? OutlinedButton(onPressed: onPressed, child: text)
          : OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: text);
    }
    return icon == null
        ? FilledButton(onPressed: onPressed, child: text)
        : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: text);
  }
}
