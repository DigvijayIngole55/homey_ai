import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/text_styles.dart';

/// A reusable section header widget that displays a title with consistent styling.
///
/// This widget is used to create headers for different sections in the app with
/// standardized padding and text styling using Inter font from Google Fonts.
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: AppTextStyles.captionStyle,
      ),
    );
  }
}
