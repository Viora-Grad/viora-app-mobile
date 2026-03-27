import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key});

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget>
    with SingleTickerProviderStateMixin {
  static const String _logoPath = 'assets/images/logo.png';
  static const Duration _animationDuration = Duration(milliseconds: 1900);
  static const Interval _fadeOutInterval = Interval(0.75, 1.0);

  late final AnimationController _controller;
  late final Animation<double> _imageOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _imageSlide;
  late final Animation<Offset> _textSlide;

  bool _isReady = false;
  bool _isDisposedFromTree = false;
  bool _isFinishEventSent = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onAnimationCompleted();
        }
      });

    _imageOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.08, curve: Curves.easeOut),
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.08, curve: Curves.easeOut),
    );

    _imageSlide = Tween<Offset>(begin: const Offset(0.45, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.24, curve: Curves.easeOutCubic),
          ),
        );

    _textSlide = Tween<Offset>(begin: const Offset(-0.45, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.24, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAndStartAnimation();
    });
  }

  Future<void> _preloadAndStartAnimation() async {
    final imageProvider = const AssetImage(_logoPath);
    await precacheImage(imageProvider, context);

    if (!mounted) {
      return;
    }

    setState(() {
      _isReady = true;
    });

    _controller.forward();
  }

  void _onAnimationCompleted() {
    if (!mounted || _isFinishEventSent) {
      return;
    }

    setState(() {
      _isDisposedFromTree = true;
      _isFinishEventSent = true;
    });

    context.read<SplashBloc>().add(const SplashLogoAnimationFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _isDisposedFromTree) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final fadeOutValue = Tween<double>(begin: 1, end: 0).transform(
                Curves.easeIn.transform(
                  _fadeOutInterval.transform(_controller.value),
                ),
              );

              return Opacity(
                opacity: fadeOutValue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _imageOpacity,
                      child: SlideTransition(
                        position: _imageSlide,
                        child: Image.asset(
                          _logoPath,
                          width: 150,
                          height: 150,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: const Text(
                          'Viora',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
