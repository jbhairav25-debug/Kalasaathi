import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiProcessingWidget extends StatefulWidget {
  final List<String> steps;
  final double progress; // 0.0 to 1.0
  final String currentStep;

  const AiProcessingWidget({
    super.key,
    required this.steps,
    required this.progress,
    required this.currentStep,
  });

  @override
  State<AiProcessingWidget> createState() => _AiProcessingWidgetState();
}

class _AiProcessingWidgetState extends State<AiProcessingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          // Animated AI icon
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB85C38), Color(0xFFD4A017)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Current step text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.currentStep,
              key: ValueKey(widget.currentStep),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Processing...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Steps list
          ...widget.steps.asMap().entries.map((e) {
            final idx = e.key;
            final step = e.value;
            final stepProgress = (idx + 1) / widget.steps.length;
            final isDone = widget.progress >= stepProgress;
            final isCurrent = widget.currentStep == step;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.primary
                          : isCurrent
                              ? AppTheme.primary.withOpacity(0.3)
                              : AppTheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : isCurrent
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDone
                          ? AppTheme.textPrimary
                          : isCurrent
                              ? AppTheme.primary
                              : AppTheme.textTertiary,
                      fontWeight: isCurrent || isDone
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
