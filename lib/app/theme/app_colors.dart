import 'package:flutter/material.dart';

/// Centralized app color tokens.
/// Import this file anywhere you need colors, so updating a hex here updates the whole app.
class AppColors {
  AppColors._();

  // ---------- Calm Base ----------
  static const Color bg = Color(0xFFF6F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1EEE7);

  static const Color border = Color(0xFFE5E0D8);
  static const Color divider = Color(0xFFEAE5DD);

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFF1E1B16);
  static const Color textSecondary = Color(0xFF5D564D);
  static const Color textTertiary = Color(0xFF8C847A);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ---------- Spark Accents ----------
  /// Used in Discover / Matches and other “dating action” moments (e.g., Super Like).
  static const Color sparkDating = Color(0xFF6D5EF8);

  /// Used for “enthusiastic exploration” moments (e.g., intimacy/preferences surfaces, playful highlights).
  /// Burnt amber: warm, vibrant, not judgment-coded.
  static const Color sparkExplore = Color(0xFFE18A2E);

  // Optional tints (useful for subtle backgrounds)
  static const Color sparkDatingSoft = Color(0xFFECEAFF);
  static const Color sparkExploreSoft = Color(0xFFFFF1E4);

  // ---------- Utility (non-judgmental) ----------
  static const Color info = Color(0xFF2F6FED);
  static const Color warning = Color(0xFFB7791F);
  static const Color danger = Color(0xFFB24A3A);

  // ---------- Gradients ----------
  /// Reflection bars (no red/green). Use with a capped value (never 100% visually).
  static const LinearGradient reflectionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [sparkDating, info],
  );
}
