import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Koyu tema · canlı vurgu (eğitim uygulamasına uygun).
/// Charcoal zemin + elektrik mavisi + mercan + mint.
abstract class AppColors {
  /// Ana zemin
  static const Color background = Color(0xFF0B0F14);
  /// Kart / app bar
  static const Color surface = Color(0xFF151A22);
  /// Input / yükseltilmiş
  static const Color surfaceElevated = Color(0xFF1E2530);
  /// Ana vurgu — elektrik mavisi
  static const Color primary = Color(0xFF4F8CFF);
  /// Soft mavi dolgu
  static const Color primarySoft = Color(0xFF1A2A45);
  static const Color primaryBorder = Color(0xFF3A5A9A);
  static const Color primaryDark = Color(0xFF3A6FE0);
  /// Mercan — CTA / sıcak vurgu
  static const Color accent = Color(0xFFFF7A59);
  static const Color accentSoft = Color(0xFF3A2420);
  /// Mint — başarı
  static const Color success = Color(0xFF3ECF8E);
  static const Color successSoft = Color(0xFF163528);
  /// Amber — uyarı
  static const Color warning = Color(0xFFFFC14D);
  static const Color warningSoft = Color(0xFF3A3018);
  /// Soft kırmızı — hata
  static const Color danger = Color(0xFFFF5A6A);
  static const Color dangerSoft = Color(0xFF3A1A22);
  /// Metin
  static const Color textPrimary = Color(0xFFF4F6F8);
  static const Color muted = Color(0xFF9AA3B2);
  static const Color border = Color(0xFF2A3340);
  static const Color navUnselected = Color(0xFF7A8494);
}

ColorScheme _buildColorScheme() {
  return ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    tertiary: AppColors.success,
    onTertiary: const Color(0xFF0B0F14),
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceElevated,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );
}

ThemeData darkTheme() {
  final colorScheme = _buildColorScheme();
  final textTheme = GoogleFonts.notoSansTextTheme(
    ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: 0,
      height: 68,
      indicatorColor: AppColors.primarySoft,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.navUnselected, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          );
        }
        return const TextStyle(
          color: AppColors.navUnselected,
          fontSize: 12,
        );
      }),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primarySoft,
      selectedColor: AppColors.primary,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(color: AppColors.primaryBorder),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.primary,
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.labelLarge,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.primary,
      textColor: AppColors.textPrimary,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surface,
      dialHandColor: AppColors.primary,
      dialBackgroundColor: AppColors.surfaceElevated,
      hourMinuteTextColor: AppColors.textPrimary,
      dayPeriodTextColor: AppColors.textPrimary,
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.all(AppColors.accent),
      todayBorder: const BorderSide(color: AppColors.accent),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      actionTextColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.muted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primarySoft;
        }
        return AppColors.border;
      }),
    ),
  );
}

/// Renkli ikon kutusu — ayarlar / liste satırları için.
class AccentIconBox extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? background;

  const AccentIconBox({
    super.key,
    required this.icon,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background ?? AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class AppTheme {
  static ThemeData get light => darkTheme();
  static ThemeData get dark => darkTheme();
}
