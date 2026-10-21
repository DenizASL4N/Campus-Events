import 'package:flutter/material.dart';

/// Colours shared by the whole app.
class AppColors {
  static const primary = Color(0xFF6D28D9);
  static const lightBackground = Color(0xFFF5F3FF);
  static const darkBackground = Color(0xFF0F0B1E);
  static const headerGradient = [
    Color(0xFF4C1D95),
    Color(0xFF7C3AED),
    Color(0xFFC026D3),
  ];
}

/// Light or dark theme; the app follows the phone setting.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  const buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        minimumSize: const Size(0, 56),
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        minimumSize: const Size(0, 56),
        side: BorderSide(color: scheme.error, width: 1.5),
        foregroundColor: scheme.error,
        textStyle: buttonText,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? scheme.surfaceContainer : Colors.white,
      indicatorColor: scheme.primaryContainer,
      elevation: 8,
      shadowColor: Colors.black26,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Background for cards and tiles: white in light mode, a raised dark
/// surface in dark mode.
Color cardColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return scheme.brightness == Brightness.dark
      ? scheme.surfaceContainerHigh
      : Colors.white;
}
