import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';

enum DarkOption { dynamic, alwaysOn, alwaysOff }

class AppTheme {
  ///Default font
  static const String defaultFont = "Almarai";

  ///List Font support
  static final List<String> fontSupport = [
    "Almarai",
    "Lemonada",
    "OpenSans",
    "ProximaNova",
    "Raleway",
    "Roboto",
    "Merriweather",
  ];

  ///Default Theme
  static final ThemeModel defaultTheme = ThemeModel.fromJson({
    "name": "default",
    // "primary": 'ffF79E16',
    "primary": 'ffFDC054',
    // "secondary": "ff2D5198",
    "secondary": "ffea3c03",
  });

  ///List Theme Support in Application
  static final List themeSupport = [
    {
      "name": "default",
      // "primary": 'ffF79E16',
      "primary": 'ffFDC054',
      // "secondary": "ff2D5198",
      "secondary": "ffea3c03",
    },
    {
      "name": "green",
      "primary": 'ff82B541',
      "secondary": "ffff8a65",
    },
    {
      "name": "orange",
      "primary": 'fff4a261',
      "secondary": "ff2A9D8F",
    }
  ].map((item) => ThemeModel.fromJson(item)).toList();

  ///Dark Theme option
  static DarkOption darkThemeOption = DarkOption.dynamic;

  ///Get theme data
  static ThemeData getTheme({
    required ThemeModel theme,
    required Brightness brightness,
    String? font,
  }) {
    ColorScheme? colorScheme;
    switch (brightness) {
      case Brightness.light:
        colorScheme = ColorScheme.light(
          primary: theme.primary,
          primaryContainer: Color.fromARGB(255, 245, 245, 245),
          onTertiary: Color.fromARGB(255, 245, 245, 245),
          tertiary: Color.fromARGB(255, 250, 250, 250),
          tertiaryContainer: Color.fromARGB(255, 235, 235, 235),
          onTertiaryContainer: Color.fromARGB(255, 210, 210, 210),
          secondary: theme.secondary,
        );
        break;
      case Brightness.dark:
        colorScheme = ColorScheme.dark(
          primary: theme.primary,
          secondary: theme.secondary,
        );
        break;
      default:
    }

    final isDark = colorScheme!.brightness == Brightness.dark;
    final indicatorColor = isDark ? colorScheme.onSurface : colorScheme.primary;

    return ThemeData(
      brightness: colorScheme.brightness,
      primaryColor: colorScheme.primary,
      // appBarTheme: AppBarTheme(
      //   backgroundColor: isDark
      //       ? Colors.white
      //       : colorScheme.secondary, //colorScheme.surface,
      //   foregroundColor: isDark ? Colors.black : Colors.white,
      //   // backgroundColor: colorScheme.surface,
      //   // foregroundColor: isDark ? Colors.white : Colors.black,
      //   shadowColor: isDark ? null : colorScheme.onSurface.withOpacity(0.2),
      // ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: isDark ? Colors.white : Colors.black,
        shadowColor: isDark ? null : colorScheme.onSurface.withOpacity(0.2),
      ),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      bottomAppBarColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withOpacity(0.12),
      backgroundColor: colorScheme.background,
      dialogBackgroundColor: colorScheme.background,
      errorColor: colorScheme.error,
      indicatorColor: indicatorColor, //Colors.white,
      applyElevationOverlayColor: isDark,
      colorScheme: colorScheme,

      ///Custom
      fontFamily: font,
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.8,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        shape: CircularNotchedRectangle(),
      ),
    );
  }

  ///export language dark option
  static String langDarkOption(DarkOption option) {
    switch (option) {
      case DarkOption.dynamic:
        return "dynamic_theme";
      case DarkOption.alwaysOff:
        return "always_off";
      default:
        return "always_on";
    }
  }

  ///Singleton factory
  static final AppTheme _instance = AppTheme._internal();

  factory AppTheme() {
    return _instance;
  }

  AppTheme._internal();
}
