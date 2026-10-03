import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Before/After comparison view for AI enhanced images
class BeforeAfterView extends StatefulWidget {
  final String beforeEmoji;
  final String afterEmoji;
  final Color beforeBg;
  final Color afterBg;

  const BeforeAfterView({
    super.key,
    required this.beforeEmoji,
    required this.afterEmoji,
    required this.beforeBg,
    required this.afterBg,
  });

  @override
  State<BeforeAfterView> createState() => _BeforeAfterViewState();
}

class _BeforeAfterViewState extends State<BeforeAfterView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Row(
        children: [
          // Before
          Expanded(
            child: Column(
              children: [
                Text(
                  'Original',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: widget.beforeBg,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.beforeEmoji,
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: AppTheme.chipRadius,
                          ),
                          child: const Text(
                            'Original Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          // After
          Expanded(
            child: Column(
              children: [
                Text(
                  'AI Enhanced',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: widget.afterBg,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.afterEmoji,
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: AppTheme.chipRadius,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('✨', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 3),
                              Text(
                                'AI Enhanced',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
