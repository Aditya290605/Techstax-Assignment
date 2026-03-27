import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Premium Light Mode Palette ───
  static const Color _primaryLight = Color(0xFF3B3486); // Deep Indigo
  static const Color _secondaryLight = Color(0xFFE8A838); // Warm Amber Gold
  static const Color _surfaceLight = Color(0xFFFAFAF8); // Warm off-white
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _accentSurfaceLight = Color(0xFFF0EEFF); // Lavender tint
  static const Color _textPrimaryLight = Color(0xFF1A1A2E);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _outlineLight = Color(0xFFE5E7EB);
  static const Color _errorLight = Color(0xFFEF4444);

  // ─── Premium Dark Mode Palette ───
  static const Color _primaryDark = Color(0xFF9B8AFB); // Soft Lavender
  static const Color _secondaryDark = Color(0xFFFBBF24); // Warm Gold
  static const Color _surfaceDark = Color(0xFF0B0B14); // Near-black with hint of blue
  static const Color _cardDark = Color(0xFF13132A); // Deep navy card
  static const Color _accentSurfaceDark = Color(0xFF1C1C3A); // Elevated surface
  static const Color _textPrimaryDark = Color(0xFFF0F0F5); // Soft white
  static const Color _textSecondaryDark = Color(0xFF9CA3AF); // Muted gray
  static const Color _outlineDark = Color(0xFF2A2A45); // Subtle border
  static const Color _errorDark = Color(0xFFF87171);

  static TextTheme _buildPremiumTextTheme(ThemeData baseTheme) {
    final baseTextTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    return baseTextTheme.copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.displayLarge,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.displayMedium,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.displaySmall,
      ),
      headlineLarge: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.headlineLarge,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.headlineMedium,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.headlineSmall,
      ),
      titleLarge: GoogleFonts.dmSerifDisplay(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: baseTextTheme.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: baseTextTheme.titleSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: baseTextTheme.bodyLarge,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: baseTextTheme.bodyMedium,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: baseTextTheme.bodySmall,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: baseTextTheme.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: baseTextTheme.labelMedium,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.inter(
        textStyle: baseTextTheme.labelSmall,
        letterSpacing: 0.4,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryLight,
        primary: _primaryLight,
        secondary: _secondaryLight,
        brightness: Brightness.light,
        surface: _surfaceLight,
        surfaceContainerHighest: _accentSurfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryLight,
        onSurfaceVariant: _textSecondaryLight,
        outline: _outlineLight,
        error: _errorLight,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: _buildPremiumTextTheme(baseTheme),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: _surfaceLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: _textPrimaryLight,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: _textPrimaryLight, size: 22),
      ),

      // ─── Input Fields ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _accentSurfaceLight.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineLight.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorLight, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.inter(
          color: _textSecondaryLight,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: _textSecondaryLight.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIconColor: _textSecondaryLight,
        suffixIconColor: _textSecondaryLight,
        floatingLabelStyle: GoogleFonts.inter(
          color: _primaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: _primaryLight.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Filled Button ───
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _primaryLight, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ─── Card ───
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _outlineLight.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        elevation: 8,
        shadowColor: _primaryLight.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        backgroundColor: _cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: _textPrimaryLight,
        ),
      ),

      // ─── FAB ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),

      // ─── Snack Bar ───
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _textPrimaryLight,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: _accentSurfaceLight,
        selectedColor: _primaryLight.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryLight;
          return _textSecondaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryLight.withValues(alpha: 0.3);
          }
          return _outlineLight;
        }),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: _outlineLight.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),

      // ─── ListTile ───
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _textPrimaryLight,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: _textSecondaryLight,
        ),
        iconColor: _textSecondaryLight,
        selectedColor: _primaryLight,
        selectedTileColor: _accentSurfaceLight,
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Progress Indicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryLight,
        linearTrackColor: _accentSurfaceLight,
      ),

      // ─── Navigation Drawer ───
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: _cardLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _accentSurfaceLight,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── Date Picker ───
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _cardLight,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primaryLight,
        headerForegroundColor: Colors.white,
        dayStyle: GoogleFonts.inter(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // ─── Segmented Button ───
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryLight.withValues(alpha: 0.12);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _primaryLight;
            return _textSecondaryLight;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: _outlineLight.withValues(alpha: 0.6)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DARK THEME (fully premium)
  // ─────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        primary: _primaryDark,
        secondary: _secondaryDark,
        brightness: Brightness.dark,
        surface: _surfaceDark,
        surfaceContainerHighest: _accentSurfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _textPrimaryDark,
        onSurfaceVariant: _textSecondaryDark,
        outline: _outlineDark,
        error: _errorDark,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: _surfaceDark,
      textTheme: _buildPremiumTextTheme(baseTheme),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surfaceDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: _textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: _textPrimaryDark, size: 22),
      ),

      // ─── Input Fields ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _accentSurfaceDark.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineDark.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineDark.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorDark, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.inter(
          color: _textSecondaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: _textSecondaryDark.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIconColor: _textSecondaryDark,
        suffixIconColor: _textSecondaryDark,
        floatingLabelStyle: GoogleFonts.inter(
          color: _primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Filled Button ───
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _primaryDark, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ─── Card ───
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _outlineDark.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        surfaceTintColor: Colors.transparent,
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: _textPrimaryDark,
        ),
      ),

      // ─── FAB ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),

      // ─── Snack Bar ───
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _accentSurfaceDark,
        contentTextStyle: GoogleFonts.inter(
          color: _textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: _accentSurfaceDark,
        selectedColor: _primaryDark.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryDark;
          return _textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryDark.withValues(alpha: 0.3);
          }
          return _outlineDark;
        }),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: _outlineDark.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),

      // ─── ListTile ───
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _textPrimaryDark,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: _textSecondaryDark,
        ),
        iconColor: _textSecondaryDark,
        selectedColor: _primaryDark,
        selectedTileColor: _accentSurfaceDark,
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Progress Indicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryDark,
        linearTrackColor: _accentSurfaceDark,
      ),

      // ─── Navigation Drawer ───
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: _cardDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _accentSurfaceDark,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── Date Picker ───
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _cardDark,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primaryDark,
        headerForegroundColor: Colors.white,
        dayStyle: GoogleFonts.inter(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // ─── Segmented Button ───
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryDark.withValues(alpha: 0.15);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _primaryDark;
            return _textSecondaryDark;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: _outlineDark.withValues(alpha: 0.6)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
