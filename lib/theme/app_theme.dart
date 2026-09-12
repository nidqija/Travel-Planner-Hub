import 'package:flutter/material.dart';

/// Design Token System based on frontend-design guidelines:
/// - Midnight Obsidian: Deep slate cinematic base
/// - Cinema Slate: Elevated frame & card surface
/// - Vapour Ion: Primary focus & algorithm telemetry
/// - Solar Amber: High relevance score & active engagement
/// - Muted Phosphor: Secondary metadata & captions
/// - Ghost Ice: Crisp typographic contrast
class AppTheme {
  static const Color midnightObsidian = Color(0xFF0D1117);
  static const Color cinemaSlate = Color(0xFF161C24);
  static const Color slateCard = Color(0xFF1F2633);
  static const Color vapourIon = Color(0xFF5686F5);
  static const Color solarAmber = Color(0xFFF5A623);
  static const Color mutedPhosphor = Color(0xFF8B9BB4);
  static const Color ghostIce = Color(0xFFF0F4F8);
  static const Color cyberEmerald = Color(0xFF00E699);
  static const Color crimsonPulse = Color(0xFFFF4757);

  // Border & Hairline colors
  static const Color frameBorder = Color(0x338B9BB4);
  static const Color frameActiveBorder = Color(0x805686F5);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnightObsidian,
      primaryColor: vapourIon,
      colorScheme: const ColorScheme.dark(
        primary: vapourIon,
        secondary: solarAmber,
        surface: cinemaSlate,
        onPrimary: Colors.white,
        onSurface: ghostIce,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: ghostIce,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: ghostIce,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: ghostIce,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: ghostIce,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: mutedPhosphor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: mutedPhosphor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
