import 'package:flutter/material.dart';

/// A reusable card widget with standardized styling.
///
/// This widget provides a consistent card container with dark background,
/// rounded corners, and customizable padding. It can wrap any widget as its child.
class StandardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const StandardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
