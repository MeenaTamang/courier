import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme blueColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      
      primary: Color.fromARGB(255, 232, 224, 178), // Beige color for primary background##
      surfaceTint: Color.fromARGB(255, 243, 187, 55), // Orange color for surface tint
      onPrimary: Color.fromARGB(255, 232, 224, 178), // White text on primary
      primaryContainer: Color(0xFFBBDEFB), // Light blue for primary container
      onPrimaryContainer: Color.fromARGB(255, 56, 114, 201), // Dark blue on container
      secondary: Color.fromARGB(247, 123, 130, 187), // Light blue for secondary
      onSecondary: Color.fromARGB(255, 225, 193, 119), // White text on secondary
      secondaryContainer:
          Color.fromARGB(247, 134, 138, 170), // Light blue for secondary container
      onSecondaryContainer: Color.fromARGB(255, 102, 126, 185), // Dark blue on container
      error: Color(0xFFD32F2F), // Red error color
      onError: Color(0xFFFFFFFF), // White text on error
      errorContainer: Color(0xFFFFCDD2), // Light red for error container
      onErrorContainer: Color(0xFFB71C1C), // Dark red on error container
      surface: Color(0xFFFFFFFF), // White surface
      onSurface: Color(0xFF212121), // Dark text on surface
      outline: Color(0xFFB0BEC5), // Outline color
      shadow: Color(0xFF000000), // Shadow color
      scrim: Color(0xFF000000), // Scrim color
      inverseSurface: Color(0xFF212121), // Inverse surface color
      inversePrimary: Color(0xFFBBDEFB), // Light blue inverse primary
    );
  }

  ThemeData light() {
    return theme(blueColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );
}
