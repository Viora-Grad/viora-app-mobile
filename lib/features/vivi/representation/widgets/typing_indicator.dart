import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _bounces;
  late final List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _bounces = List.generate(3, (i) {
      final offset = i * 0.25;
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(offset, offset + 0.5, curve: Curves.easeInOut),
        ),
      );
    });

    _scales = List.generate(3, (i) {
      final offset = i * 0.25;
      return Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(offset, offset + 0.5, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54, top: 4, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F3FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Transform.translate(
                  offset: Offset(0, _bounces[i].value),
                  child: Transform.scale(
                    scale: _scales[i].value,
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        color:
                            (_scales[i].value > 1.0
                                    ? const Color(0xFF2F1193)
                                    : Colors.grey)
                                .withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
