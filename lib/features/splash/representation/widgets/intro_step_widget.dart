import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroStepWidget extends StatefulWidget {
  const IntroStepWidget({
    super.key,
    required this.assetPath,
    required this.message,
    required this.onContinue,
    this.onBack,
    this.continueIcon = Icons.arrow_forward,
    this.maxTextWidth = 400,
  });

  final String assetPath;
  final String message;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final IconData continueIcon;
  final double maxTextWidth;

  @override
  State<IntroStepWidget> createState() => _IntroStepWidgetState();
}

class _IntroStepWidgetState extends State<IntroStepWidget> {
  static const Duration _fadeDuration = Duration(milliseconds: 200);
  static const Color _backgroundColor = Color(0xFF240D37);

  bool _isVisible = false;
  bool _isCompleting = false;
  bool _isDisposedFromTree = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _isVisible = true);
    });
  }

  Future<void> _runTransition(VoidCallback action) async {
    if (_isCompleting || _isDisposedFromTree) {
      return;
    }

    setState(() {
      _isCompleting = true;
      _isVisible = false;
    });

    await Future<void>.delayed(_fadeDuration);

    if (!mounted) {
      return;
    }

    setState(() {
      _isDisposedFromTree = true;
    });

    action();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposedFromTree) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final animationWidth = math.min(screenWidth * 0.86, 500.0);
    final animationHeight = animationWidth * 0.8;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: _fadeDuration,
              child: Center(
                child: RepaintBoundary(
                  child: Lottie.asset(
                    widget.assetPath,
                    repeat: true,
                    animate: true,
                    width: animationWidth,
                    height: animationHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: _fadeDuration,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.maxTextWidth,
                    maxHeight: 200,
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: _fadeDuration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onBack != null) ...[
                    ElevatedButton(
                      onPressed: _isCompleting
                          ? null
                          : () => _runTransition(widget.onBack!),
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 50),
                  ],
                  ElevatedButton(
                    onPressed: _isCompleting
                        ? null
                        : () => _runTransition(widget.onContinue),
                    child: Icon(widget.continueIcon),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
