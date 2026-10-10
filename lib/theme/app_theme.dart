import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ثيم تطبيق كابتن بارتي.
/// اللون الأساسي #4F0E5E وتدرجاته مأخوذة من شعار التطبيق.
/// ملاحظة: تم إلغاء letterSpacing لأنه يفصل حروف الخط العربي عن بعضها.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // تدرجات اللون الأساسي (من الأفتح إلى الأغمق)
  // ---------------------------------------------------------------------------
  static const Color p50 = Color(0xFFF8F1FA);
  static const Color p100 = Color(0xFFEBD6F0);
  static const Color p200 = Color(0xFFD7ADE0);
  static const Color p300 = Color(0xFFC085CE);
  static const Color p400 = Color(0xFF9F4FB3);
  static const Color p500 = Color(0xFF7C2A92);
  static const Color p600 = Color(0xFF651A7A);
  static const Color p700 = Color(0xFF4F0E5E); // اللون الأساسي
  static const Color p800 = Color(0xFF3B0A47);
  static const Color p900 = Color(0xFF2D0836);

  /// تدرج رئيسي للترويسات والأزرار المميزة
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [p700, p500, p400],
  );

  /// تدرج داكن لشاشة البداية
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [p900, p700, p600],
  );

  // ---------------------------------------------------------------------------
  // الألوان (نفس الأسماء القديمة حتى لا تتعطل بقية الشاشات)
  // ---------------------------------------------------------------------------
  static const Color primary = p700;
  static const Color primaryLight = p400;
  static const Color primaryDark = p900;
  static const Color secondary = Color(0xFFF8F4F9);
  static const Color accent = p100;
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F4F9);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFF1A1A1A);
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFFFFFFFF);

  static const Color cardLight = Color(0xFFF8F4F9);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D2D2D);

  static const Color shadowLight = Color(0x26000000);
  static const Color shadowDark = Color(0x26FFFFFF);

  static const Color dividerLight = Color(0x334F0E5E);
  static const Color dividerDark = Color(0x339F4FB3);

  static const Color textHighEmphasisLight = Color(0xFF1A1A1A);
  static const Color textMediumEmphasisLight = Color(0xFF666666);
  static const Color textDisabledLight = Color(0x611A1A1A);

  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0x99FFFFFF);
  static const Color textDisabledDark = Color(0x61FFFFFF);

  static ThemeData lightTheme = _build(light: true);
  static ThemeData darkTheme = _build(light: false);

  // ---------------------------------------------------------------------------
  static ThemeData _build({required bool light}) {
    final Color pri = light ? primary : primaryLight;
    final Color onPri = light ? onPrimaryLight : onPrimaryDark;
    final Color bg = light ? backgroundLight : backgroundDark;
    final Color surf = light ? surfaceLight : surfaceDark;
    final Color card = light ? cardLight : cardDark;
    final Color txt = light ? textHighEmphasisLight : textHighEmphasisDark;
    final Color txt2 = light ? textSecondary : textMediumEmphasisDark;
    final Color hint = light ? textDisabledLight : textDisabledDark;
    final Color divider = light ? dividerLight : dividerDark;
    final Color shadow = light ? shadowLight : shadowDark;
    final TextTheme tt = _buildTextTheme(isLight: light);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      brightness: light ? Brightness.light : Brightness.dark,
      colorScheme: ColorScheme(
        brightness: light ? Brightness.light : Brightness.dark,
        primary: pri,
        onPrimary: onPri,
        primaryContainer: light ? p100 : primary,
        onPrimaryContainer: light ? p900 : onPrimaryLight,
        secondary: light ? secondary : surfaceDark,
        onSecondary: light ? onSecondaryLight : onSecondaryDark,
        secondaryContainer: light ? accent : cardDark,
        onSecondaryContainer: light ? onSecondaryLight : onSecondaryDark,
        tertiary: accent,
        onTertiary: onSecondaryLight,
        tertiaryContainer: light ? secondary : surfaceDark,
        onTertiaryContainer: light ? onSecondaryLight : onSecondaryDark,
        error: error,
        onError: light ? onErrorLight : onErrorDark,
        surface: surf,
        onSurface: txt,
        onSurfaceVariant: txt2,
        outline: divider,
        outlineVariant: divider,
        shadow: shadow,
        scrim: shadow,
        inverseSurface: light ? surfaceDark : surfaceLight,
        onInverseSurface: light ? onSurfaceDark : onSurfaceLight,
        inversePrimary: light ? primaryLight : primary,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: card,
      dividerColor: divider,
      textTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: txt,
        elevation: 0,
        centerTitle: true,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: tt.titleLarge,
        iconTheme: IconThemeData(color: txt, size: 24),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 2.0,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: pri,
        unselectedItemColor: txt2,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle:
            GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: pri,
        foregroundColor: onPri,
        elevation: 6.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPri,
          backgroundColor: pri,
          elevation: 2.0,
          shadowColor: shadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pri,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: pri, width: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: pri,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: light ? backgroundLight : surfaceDark,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(divider),
        enabledBorder: border(divider),
        focusedBorder: border(pri, 2),
        errorBorder: border(error),
        focusedErrorBorder: border(error, 2),
        labelStyle: GoogleFonts.cairo(color: txt2, fontSize: 15),
        hintStyle: GoogleFonts.cairo(color: hint, fontSize: 15),
        errorStyle: GoogleFonts.cairo(color: error, fontSize: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? pri : txt2),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? pri.withAlpha(77)
                : txt2.withAlpha(77)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? pri : Colors.transparent),
        checkColor: WidgetStateProperty.all(onPri),
        side: BorderSide(color: pri, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? pri : txt2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: pri,
        linearTrackColor: accent,
        circularTrackColor: accent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: pri,
        thumbColor: pri,
        overlayColor: pri.withAlpha(51),
        inactiveTrackColor: accent,
        valueIndicatorColor: pri,
        valueIndicatorTextStyle:
            GoogleFonts.cairo(color: onPri, fontSize: 12),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: pri,
        unselectedLabelColor: txt2,
        indicatorColor: pri,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle:
            GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: txt.withAlpha(230),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.cairo(color: bg, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: light ? primaryDark : p100,
        contentTextStyle: GoogleFonts.cairo(
            color: light ? Colors.white : primaryDark, fontSize: 14),
        actionTextColor: light ? p200 : primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8.0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 8.0,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 15, fontWeight: FontWeight.w600, color: txt),
        subtitleTextStyle: GoogleFonts.cairo(fontSize: 13, color: txt2),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: light ? dialogLight : dialogDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color hi = isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color med =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color dis = isLight ? textDisabledLight : textDisabledDark;

    TextStyle s(double size, FontWeight w, Color c) => GoogleFonts.cairo(
          fontSize: size,
          fontWeight: w,
          color: c,
          letterSpacing: 0, // مهم للعربية
        );

    return TextTheme(
      displayLarge: s(57, FontWeight.w700, hi),
      displayMedium: s(45, FontWeight.w700, hi),
      displaySmall: s(36, FontWeight.w700, hi),
      headlineLarge: s(32, FontWeight.w700, hi),
      headlineMedium: s(28, FontWeight.w700, hi),
      headlineSmall: s(22, FontWeight.w700, hi),
      titleLarge: s(20, FontWeight.w700, hi),
      titleMedium: s(16, FontWeight.w700, hi),
      titleSmall: s(14, FontWeight.w600, hi),
      bodyLarge: s(16, FontWeight.w400, hi),
      bodyMedium: s(14, FontWeight.w400, hi),
      bodySmall: s(12, FontWeight.w400, med),
      labelLarge: s(14, FontWeight.w600, hi),
      labelMedium: s(12, FontWeight.w600, med),
      labelSmall: s(11, FontWeight.w400, dis),
    );
  }

  /// نمط للأرقام (الأسعار، أرقام الهواتف، مراجع الحجز)
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textHighEmphasisLight : textHighEmphasisDark,
      letterSpacing: 0,
    );
  }
}
