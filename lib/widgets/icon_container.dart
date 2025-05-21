import 'package:flutter/material.dart';

/// A reusable circular container with an icon.
///
/// This widget creates a circular container with a semi-transparent background
/// based on the provided color, and displays an icon in the center with the
/// same color. The container has fixed dimensions of 48x48.
class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
