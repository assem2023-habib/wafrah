import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  Color c(Color light, Color dark) => isDark ? dark : light;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c(AppColors.primary, AppColors.darkPrimary),
    onPrimary: c(AppColors.onPrimary, AppColors.darkOnPrimary),
    secondary: c(AppColors.secondary, AppColors.darkSecondary),
    onSecondary: c(AppColors.onSecondary, AppColors.darkOnSecondary),
    tertiary: c(AppColors.secondary, AppColors.darkSecondary),
    onTertiary: c(AppColors.onSecondary, AppColors.darkOnSecondary),
    error: c(AppColors.danger, AppColors.darkDanger),
    onError: c(AppColors.surface, AppColors.darkSurface),
    errorContainer: c(AppColors.dangerBg, AppColors.darkDangerBg),
    onErrorContainer: c(AppColors.danger, AppColors.darkDanger),
    surface: c(AppColors.surface, AppColors.darkSurface),
    onSurface: c(AppColors.textPrimary, AppColors.darkTextPrimary),
    onSurfaceVariant: c(AppColors.textSecondary, AppColors.darkTextSecondary),
    surfaceContainerLowest: c(AppColors.background, AppColors.darkBackground),
    surfaceContainerLow: c(AppColors.surface, AppColors.darkSurface),
    surfaceContainer: c(AppColors.surface, AppColors.darkSurface),
    surfaceContainerHigh: c(AppColors.surface, AppColors.darkSurface),
    surfaceContainerHighest: c(AppColors.muted, AppColors.darkMuted),
    surfaceDim: c(AppColors.muted, AppColors.darkMuted),
    surfaceBright: c(AppColors.surface, AppColors.darkSurface),
    outline: c(AppColors.border, AppColors.darkBorder),
    outlineVariant: c(AppColors.border, AppColors.darkBorder),
    inverseSurface: c(AppColors.textPrimary, AppColors.darkTextPrimary),
    onInverseSurface: c(AppColors.surface, AppColors.darkSurface),
    inversePrimary: c(AppColors.primary, AppColors.darkPrimary),
    surfaceTint: Colors.transparent,
  );

  const radiusMd = BorderRadius.all(Radius.circular(AppDimens.radiusMd));
  const radiusLg = BorderRadius.all(Radius.circular(AppDimens.radiusLg));

  final surfaceColor = c(AppColors.surface, AppColors.darkSurface);
  final textPrimaryColor = c(AppColors.textPrimary, AppColors.darkTextPrimary);
  final primaryColor = c(AppColors.primary, AppColors.darkPrimary);
  final borderColor = c(AppColors.border, AppColors.darkBorder);
  final dangerColor = c(AppColors.danger, AppColors.darkDanger);

  final buttonTextStyle = TextStyle(
    fontSize: AppDimens.fontSizeBody,
    fontWeight: AppDimens.fontWeightMedium,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: c(AppColors.background, AppColors.darkBackground),
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppDimens.fontSizeHeading,
        fontWeight: AppDimens.fontWeightMedium,
        color: textPrimaryColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radiusLg,
        side: BorderSide(color: borderColor),
      ),
    ),
    dividerTheme: DividerThemeData(color: borderColor),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      labelStyle: TextStyle(
        fontSize: AppDimens.fontSizeLabel,
        color: c(AppColors.textSecondary, AppColors.darkTextSecondary),
      ),
      border: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: dangerColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: dangerColor),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          const Size(0, AppDimens.buttonHeight),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radiusMd),
        ),
        textStyle: WidgetStatePropertyAll(buttonTextStyle),
        foregroundColor: WidgetStatePropertyAll(
          c(AppColors.onPrimary, AppColors.darkOnPrimary),
        ),
        backgroundColor: WidgetStatePropertyAll(primaryColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          const Size(0, AppDimens.buttonHeight),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radiusMd),
        ),
        textStyle: WidgetStatePropertyAll(buttonTextStyle),
        foregroundColor: WidgetStatePropertyAll(primaryColor),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          const Size(0, AppDimens.buttonHeight),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radiusMd),
        ),
        textStyle: WidgetStatePropertyAll(buttonTextStyle),
        foregroundColor: WidgetStatePropertyAll(primaryColor),
        side: WidgetStatePropertyAll(BorderSide(color: primaryColor)),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primaryColor
            : c(AppColors.switchBackground, AppColors.darkSwitchBackground),
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? c(AppColors.onPrimary, AppColors.darkOnPrimary)
            : surfaceColor,
      ),
    ),
  );
}
