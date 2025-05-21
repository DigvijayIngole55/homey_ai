import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A collection of text styles used throughout the app.
/// All styles use the Inter font family from Google Fonts.
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  /// Style for main screen titles
  /// Font: Inter, Size: 24, Weight: SemiBold
  static final screenTitleStyle = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  /// Style for section titles
  /// Font: Inter, Size: 18, Weight: SemiBold
  static final sectionTitleStyle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Style for body text
  /// Font: Inter, Size: 16
  static final bodyTextStyle = GoogleFonts.inter(
    fontSize: 16,
  );

  /// Style for captions and secondary text
  /// Font: Inter, Size: 14, Color: Grey
  static final captionStyle = GoogleFonts.inter(
    fontSize: 14,
    color: Colors.grey[400],
  );
}
