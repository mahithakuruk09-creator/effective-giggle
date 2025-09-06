import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scredex_design_system/scredex_theme.dart';

// Banklink-inspired color tokens
class AppColors {
  static const primary = Color(0xFF1E1E2E); // dark base
  static const secondary = Color(0xFF2A2A3D); // panels
  static const textMain = Color(0xFFF1F1F1);
  static const textMuted = Color(0xFF9A9A9A);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);

  static const accentStart = Color(0xFF6D77FF); // indigo
  static const accentEnd = Color(0xFF9C4DFF); // violet
}

// Glass utilities
class Glass {
  static BoxDecoration decoration({double radius = 24}) => BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double height;
  final double? width;
  final double radius;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.height = 0, this.width, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height == 0 ? null : height,
      decoration: Glass.decoration(radius: radius),
      padding: padding,
      child: child,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: card,
      ),
    );
  }
}

// Gradient primary button
class AppButtons {
  static Widget primary({required String label, required VoidCallback? onPressed, IconData? icon}) {
    final gradient = const LinearGradient(colors: [AppColors.accentStart, AppColors.accentEnd]);
    final content = Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
    final child = Ink(
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: const BoxConstraints(minWidth: 64),
        alignment: Alignment.center,
        child: content,
      ),
    );
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        shadowColor: AppColors.accentEnd.withOpacity(0.4),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ).merge(ButtonStyle(
        // Keep surface transparent; gradient lives in Ink container
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        overlayColor: MaterialStateProperty.resolveWith((s) => Colors.white.withOpacity(s.contains(MaterialState.pressed) ? 0.06 : 0.02)),
      )),
      onPressed: onPressed,
      child: child,
    );
  }
}

class AppTheme {
  static ThemeData dark({bool highContrast = false}) {
    final base = ScredexTheme.dark;
    final accent = const LinearGradient(colors: [AppColors.accentStart, AppColors.accentEnd]);
    final cs = base.colorScheme.copyWith(
      primary: AppColors.textMain,
      secondary: AppColors.textMuted,
      surface: AppColors.primary,
      error: AppColors.error,
    );
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.primary,
      canvasColor: AppColors.primary,
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.05),
      textTheme: base.textTheme.apply(
        bodyColor: highContrast ? Colors.white : AppColors.textMain,
        displayColor: highContrast ? Colors.white : AppColors.textMain,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textMain,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.06),
        shadowColor: Colors.black.withOpacity(0.35),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: Colors.white,
          backgroundColor: AppColors.accentEnd,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) => s.contains(MaterialState.selected) ? AppColors.accentEnd : Colors.grey.shade600),
        trackColor: MaterialStateProperty.resolveWith((s) => s.contains(MaterialState.selected) ? AppColors.accentStart.withOpacity(0.5) : Colors.grey.shade800),
      ),
      tabBarTheme: const TabBarTheme(
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: AppColors.accentEnd, width: 3)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black.withOpacity(0.4),
        modalBackgroundColor: AppColors.secondary.withOpacity(0.85),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black.withOpacity(0.2),
        selectedItemColor: AppColors.textMain,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// Simple theme controller for high contrast toggle
final highContrastProvider = StateProvider<bool>((_) => false);
final appThemeProvider = Provider<ThemeData>((ref) {
  final hc = ref.watch(highContrastProvider);
  return AppTheme.dark(highContrast: hc);
});

