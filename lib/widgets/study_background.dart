import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class StudyBackground extends StatefulWidget {
  final Widget child;

  const StudyBackground({
    super.key,
    required this.child,
  });

  @override
  State<StudyBackground> createState() => _StudyBackgroundState();
}

class _StudyBackgroundState extends State<StudyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<_FloatingIconData> _floatingIcons = [
    _FloatingIconData(
      icon: Icons.menu_book_rounded,
      alignment: Alignment(-0.85, -0.65),
      size: 32,
      color: Color(0xFF4F46E5),
      opacity: 0.15,
      rotation: -0.2,
      phaseOffset: 0.0,
      floatDistance: 12.0,
    ),
    _FloatingIconData(
      icon: Icons.lightbulb_outline_rounded,
      alignment: Alignment(0.82, -0.75),
      size: 36,
      color: Color(0xFFF59E0B),
      opacity: 0.16,
      rotation: 0.25,
      phaseOffset: 1.2,
      floatDistance: 14.0,
    ),
    _FloatingIconData(
      icon: Icons.science_outlined,
      alignment: Alignment(-0.75, -0.2),
      size: 30,
      color: Color(0xFF0D9488),
      opacity: 0.15,
      rotation: -0.3,
      phaseOffset: 2.5,
      floatDistance: 10.0,
    ),
    _FloatingIconData(
      icon: Icons.school_outlined,
      alignment: Alignment(0.88, -0.25),
      size: 34,
      color: Color(0xFF2563EB),
      opacity: 0.14,
      rotation: 0.15,
      phaseOffset: 0.8,
      floatDistance: 13.0,
    ),
    _FloatingIconData(
      icon: Icons.psychology_outlined,
      alignment: Alignment(-0.82, 0.25),
      size: 38,
      color: Color(0xFF7C3AED),
      opacity: 0.15,
      rotation: -0.15,
      phaseOffset: 3.1,
      floatDistance: 15.0,
    ),
    _FloatingIconData(
      icon: Icons.calculate_outlined,
      alignment: Alignment(0.78, 0.22),
      size: 28,
      color: Color(0xFF059669),
      opacity: 0.16,
      rotation: 0.35,
      phaseOffset: 4.0,
      floatDistance: 11.0,
    ),
    _FloatingIconData(
      icon: Icons.emoji_events_outlined,
      alignment: Alignment(-0.72, 0.68),
      size: 32,
      color: Color(0xFFEA580C),
      opacity: 0.15,
      rotation: -0.25,
      phaseOffset: 1.8,
      floatDistance: 12.0,
    ),
    _FloatingIconData(
      icon: Icons.timer_outlined,
      alignment: Alignment(0.85, 0.72),
      size: 30,
      color: Color(0xFFDB2777),
      opacity: 0.15,
      rotation: 0.2,
      phaseOffset: 3.5,
      floatDistance: 14.0,
    ),
    _FloatingIconData(
      icon: Icons.memory_rounded,
      alignment: Alignment(-0.35, -0.82),
      size: 26,
      color: Color(0xFF4F46E5),
      opacity: 0.12,
      rotation: 0.1,
      phaseOffset: 2.1,
      floatDistance: 10.0,
    ),
    _FloatingIconData(
      icon: Icons.code_rounded,
      alignment: Alignment(0.38, 0.82),
      size: 28,
      color: Color(0xFF0D9488),
      opacity: 0.13,
      rotation: -0.18,
      phaseOffset: 4.8,
      floatDistance: 12.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Stack(
      children: [
        // Layer 1: Soft Gradient Base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [
                      AppTokens.bgDark,
                      Color(0xFF12172D),
                      AppTokens.surfaceDark,
                    ]
                  : const [
                      Color(0xFFEEF1FF), // Soft lavender tint
                      AppTokens.bgLight, // Slate 50
                      Color(0xFFFFFFFF), // Pure white
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Layer 2: Decorative Gradient Corner Blobs
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? AppTokens.primaryIndigoDark : AppTokens.primaryIndigoLight)
                  .withValues(alpha: isDark ? 0.06 : 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.06 : 0.08),
            ),
          ),
        ),

        // Layer 3: Seamless Study Pattern Tile Texture
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/image/study_pattern.png'),
                repeat: ImageRepeat.repeat,
                opacity: isDark ? 0.04 : 0.08,
                fit: BoxFit.none,
                scale: 2.0,
              ),
            ),
          ),
        ),

        // Layer 4: Floating Decorative Icons (IgnorePointer + RepaintBoundary)
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                return Stack(
                  children: _floatingIcons.map((data) {
                    final delta = math.sin((progress * 2 * math.pi) + data.phaseOffset);
                    final dy = delta * data.floatDistance;
                    final dr = data.rotation + (delta * 0.05);

                    return Align(
                      alignment: data.alignment,
                      child: Transform.translate(
                        offset: Offset(0, dy),
                        child: Transform.rotate(
                          angle: dr,
                          child: Icon(
                            data.icon,
                            size: data.size,
                            color: data.color.withValues(alpha: isDark ? data.opacity * 0.8 : data.opacity),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),

        // Layer 5: Main Content
        widget.child,
      ],
    );
  }
}

class _FloatingIconData {
  final IconData icon;
  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;
  final double rotation;
  final double phaseOffset;
  final double floatDistance;

  const _FloatingIconData({
    required this.icon,
    required this.alignment,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
    required this.phaseOffset,
    required this.floatDistance,
  });
}
