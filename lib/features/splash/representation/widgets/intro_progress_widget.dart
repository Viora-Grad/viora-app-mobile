import 'package:flutter/material.dart';

class IntroProgressWidget extends StatelessWidget {
  const IntroProgressWidget({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  static const Duration _duration = Duration(milliseconds: 420);
  static const Color _activeColor = Color(0xFF00E5FF);
  static const Color _inactiveColor = Color(0xFF3A2C57);

  @override
  Widget build(BuildContext context) {
    final clampedCurrentStep = currentStep.clamp(1, totalSteps);

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          final stepNumber = (index ~/ 2) + 1;
          return _StepCircle(
            stepNumber: stepNumber,
            isActive: stepNumber <= clampedCurrentStep,
            isCurrent: stepNumber == clampedCurrentStep,
          );
        }

        final connectorIndex = (index - 1) ~/ 2;
        final isFilled = connectorIndex < clampedCurrentStep - 1;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _AnimatedConnector(isFilled: isFilled),
          ),
        );
      }),
    );
  }
}

class _AnimatedConnector extends StatelessWidget {
  const _AnimatedConnector({required this.isFilled});

  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isFilled ? 1 : 0),
        duration: IntroProgressWidget._duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: IntroProgressWidget._inactiveColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      IntroProgressWidget._inactiveColor,
                      IntroProgressWidget._activeColor,
                      value,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.isActive,
    required this.isCurrent,
  });

  final int stepNumber;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: isCurrent ? 1.05 : 1),
      duration: IntroProgressWidget._duration,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: IntroProgressWidget._duration,
            curve: Curves.easeOutCubic,
            width: isCurrent ? 34 : 30,
            height: isCurrent ? 34 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? IntroProgressWidget._activeColor
                  : IntroProgressWidget._inactiveColor,
              boxShadow: isCurrent && isActive
                  ? const [
                      BoxShadow(
                        color: Color(0x6600E5FF),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}
