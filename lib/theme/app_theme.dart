import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class QuizThemeExtension extends ThemeExtension<QuizThemeExtension> {
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color successColor;
  final Color successBackground;
  final Color errorColor;
  final Color errorBackground;
  final Color warningColor;
  final Color warningBackground;
  final Color infoColor;
  final Color infoBackground;
  final List<Color> headerGradient;
  final Color easyColor;
  final Color mediumColor;
  final Color hardColor;

  const QuizThemeExtension({
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.successColor,
    required this.successBackground,
    required this.errorColor,
    required this.errorBackground,
    required this.warningColor,
    required this.warningBackground,
    required this.infoColor,
    required this.infoBackground,
    required this.headerGradient,
    required this.easyColor,
    required this.mediumColor,
    required this.hardColor,
  });

  @override
  QuizThemeExtension copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? successColor,
    Color? successBackground,
    Color? errorColor,
    Color? errorBackground,
    Color? warningColor,
    Color? warningBackground,
    Color? infoColor,
    Color? infoBackground,
    List<Color>? headerGradient,
    Color? easyColor,
    Color? mediumColor,
    Color? hardColor,
  }) {
    return QuizThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      successColor: successColor ?? this.successColor,
      successBackground: successBackground ?? this.successBackground,
      errorColor: errorColor ?? this.errorColor,
      errorBackground: errorBackground ?? this.errorBackground,
      warningColor: warningColor ?? this.warningColor,
      warningBackground: warningBackground ?? this.warningBackground,
      infoColor: infoColor ?? this.infoColor,
      infoBackground: infoBackground ?? this.infoBackground,
      headerGradient: headerGradient ?? this.headerGradient,
      easyColor: easyColor ?? this.easyColor,
      mediumColor: mediumColor ?? this.mediumColor,
      hardColor: hardColor ?? this.hardColor,
    );
  }

  @override
  QuizThemeExtension lerp(ThemeExtension<QuizThemeExtension>? other, double t) {
    if (other is! QuizThemeExtension) return this;
    return QuizThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      successBackground: Color.lerp(successBackground, other.successBackground, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      headerGradient: [
        Color.lerp(headerGradient.first, other.headerGradient.first, t)!,
        Color.lerp(headerGradient[1], other.headerGradient[1], t)!,
        Color.lerp(headerGradient.last, other.headerGradient.last, t)!,
      ],
      easyColor: Color.lerp(easyColor, other.easyColor, t)!,
      mediumColor: Color.lerp(mediumColor, other.mediumColor, t)!,
      hardColor: Color.lerp(hardColor, other.hardColor, t)!,
    );
  }
}

extension QuizThemeContext on BuildContext {
  QuizThemeExtension get quizTheme =>
      Theme.of(this).extension<QuizThemeExtension>() ?? AppTheme.lightExtension;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static const lightExtension = QuizThemeExtension(
    cardBackground: AppTokens.surfaceLight,
    cardBorder: AppTokens.borderLight,
    textPrimary: AppTokens.textPrimaryLight,
    textSecondary: AppTokens.textSecondaryLight,
    textMuted: AppTokens.textMutedLight,
    successColor: AppTokens.successLight,
    successBackground: AppTokens.successBgLight,
    errorColor: AppTokens.errorLight,
    errorBackground: AppTokens.errorBgLight,
    warningColor: AppTokens.warningLight,
    warningBackground: AppTokens.warningBgLight,
    infoColor: AppTokens.infoLight,
    infoBackground: AppTokens.infoBgLight,
    headerGradient: AppTokens.headerGradientLight,
    easyColor: AppTokens.difficultyEasy,
    mediumColor: AppTokens.difficultyMedium,
    hardColor: AppTokens.difficultyHard,
  );

  static const darkExtension = QuizThemeExtension(
    cardBackground: AppTokens.surfaceDark,
    cardBorder: AppTokens.borderDark,
    textPrimary: AppTokens.textPrimaryDark,
    textSecondary: AppTokens.textSecondaryDark,
    textMuted: AppTokens.textMutedDark,
    successColor: AppTokens.successDark,
    successBackground: AppTokens.successBgDark,
    errorColor: AppTokens.errorDark,
    errorBackground: AppTokens.errorBgDark,
    warningColor: AppTokens.warningDark,
    warningBackground: AppTokens.warningBgDark,
    infoColor: AppTokens.infoDark,
    infoBackground: AppTokens.infoBgDark,
    headerGradient: AppTokens.headerGradientDark,
    easyColor: AppTokens.difficultyEasy,
    mediumColor: AppTokens.difficultyMedium,
    hardColor: AppTokens.difficultyHard,
  );

  static TextTheme _buildTextTheme(
    Brightness brightness,
    Color primaryText,
    Color secondaryText,
    Color mutedText,
  ) {
    TextStyle jakartaStyle({
      required double fontSize,
      required FontWeight fontWeight,
      double? letterSpacing,
      double? height,
      Color? color,
      List<FontFeature>? fontFeatures,
    }) {
      final base = TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? primaryText,
        fontFeatures: fontFeatures,
      );
      try {
        return GoogleFonts.plusJakartaSans(textStyle: base);
      } catch (_) {
        return base;
      }
    }

    TextStyle interStyle({
      required double fontSize,
      required FontWeight fontWeight,
      double? letterSpacing,
      double? height,
      Color? color,
      List<FontFeature>? fontFeatures,
    }) {
      final base = TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? primaryText,
        fontFeatures: fontFeatures,
      );
      try {
        return GoogleFonts.inter(textStyle: base);
      } catch (_) {
        return base;
      }
    }

    return TextTheme(
      displayLarge: jakartaStyle(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1.0),
      headlineLarge: jakartaStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: jakartaStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleLarge: jakartaStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: jakartaStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: interStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45),
      bodyMedium: interStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: secondaryText),
      bodySmall: interStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedText),
      labelLarge: interStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: interStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelSmall: interStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedText),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      Brightness.light,
      AppTokens.textPrimaryLight,
      AppTokens.textSecondaryLight,
      AppTokens.textMutedLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppTokens.primaryIndigoLight,
      scaffoldBackgroundColor: AppTokens.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.primaryIndigoLight,
        secondary: Color(0xFF7C3AED),
        surface: AppTokens.surfaceLight,
        error: AppTokens.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppTokens.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.windows: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.macOS: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.linux: FadeSlidePageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppTokens.primaryIndigoLight,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: const BorderSide(color: AppTokens.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
          backgroundColor: AppTokens.primaryIndigoLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
          foregroundColor: AppTokens.primaryIndigoLight,
          side: const BorderSide(color: AppTokens.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primaryIndigoLight,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusButton),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.primaryIndigoLight, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.borderLight,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.primaryIndigoLight,
        linearTrackColor: AppTokens.borderLight,
      ),
      extensions: const [lightExtension],
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      Brightness.dark,
      AppTokens.textPrimaryDark,
      AppTokens.textSecondaryDark,
      AppTokens.textMutedDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppTokens.primaryIndigoDark,
      scaffoldBackgroundColor: AppTokens.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.primaryIndigoDark,
        secondary: Color(0xFFA78BFA),
        surface: AppTokens.surfaceDark,
        error: AppTokens.errorDark,
        onPrimary: Color(0xFF0F1020),
        onSecondary: Color(0xFF0F1020),
        onSurface: AppTokens.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.windows: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.macOS: FadeSlidePageTransitionsBuilder(),
          TargetPlatform.linux: FadeSlidePageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppTokens.surfaceDark,
        foregroundColor: AppTokens.textPrimaryDark,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppTokens.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: const BorderSide(color: AppTokens.borderDark),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
          backgroundColor: AppTokens.primaryIndigoDark,
          foregroundColor: const Color(0xFF0F1020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
          foregroundColor: AppTokens.primaryIndigoDark,
          side: const BorderSide(color: AppTokens.borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primaryIndigoDark,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusButton),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2035),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.primaryIndigoDark, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.borderDark,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.primaryIndigoDark,
        linearTrackColor: AppTokens.borderDark,
      ),
      extensions: const [darkExtension],
    );
  }
}

class FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.04);
    const end = Offset.zero;
    final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
    final fadeTween =
        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }
}
