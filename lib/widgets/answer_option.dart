import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class AnswerOption extends StatefulWidget {
  final String optionLabel; // "A", "B", "C", "D"
  final String optionText;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;
  final Color themeColor;

  const AnswerOption({
    super.key,
    required this.optionLabel,
    required this.optionText,
    required this.isSelected,
    this.isDimmed = false,
    required this.onTap,
    required this.themeColor,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final quizTheme = context.quizTheme;
    final isDark = context.isDarkMode;
    final activeColor = widget.themeColor;

    final borderColor = widget.isSelected
        ? activeColor
        : (_isHovered
            ? activeColor.withValues(alpha: 0.5)
            : quizTheme.cardBorder);

    final backgroundColor = widget.isSelected
        ? activeColor.withValues(alpha: isDark ? 0.22 : 0.08)
        : (_isHovered
            ? activeColor.withValues(alpha: isDark ? 0.10 : 0.03)
            : quizTheme.cardBackground);

    final double opacity = (widget.isDimmed && !widget.isSelected) ? 0.45 : 1.0;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: 'Option ${widget.optionLabel}: ${widget.optionText}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: opacity,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                border: Border.all(
                  color: borderColor,
                  width: widget.isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: activeColor.withValues(alpha: isDark ? 0.28 : 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  else if (_isHovered)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                  splashColor: activeColor.withValues(alpha: 0.12),
                  highlightColor: activeColor.withValues(alpha: 0.05),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        children: [
                          // Badge (A, B, C, D)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? activeColor
                                  : (isDark ? const Color(0xFF232A42) : const Color(0xFFF1F5F9)),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isSelected
                                    ? activeColor
                                    : quizTheme.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.optionLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isSelected
                                      ? Colors.white
                                      : quizTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Option Text
                          Expanded(
                            child: Text(
                              widget.optionText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: widget.isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: quizTheme.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right Icon: check_circle icon on selected
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: widget.isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    key: const ValueKey('check'),
                                    color: activeColor,
                                    size: 24,
                                  )
                                : const SizedBox(
                                    key: ValueKey('none'),
                                    width: 24,
                                    height: 24,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
