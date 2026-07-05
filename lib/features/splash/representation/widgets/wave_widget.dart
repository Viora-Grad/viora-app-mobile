import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';

class WaveWidget extends StatefulWidget {
  const WaveWidget({super.key});

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 1900);
  static const Color _violet = Color(0xFF240D37);

  late final AnimationController _controller;
  late final Animation<double> _waveTopFactor;

  bool _isFinishEventSent = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onWaveAnimationCompleted();
        }
      })
      ..forward();

    _waveTopFactor = Tween<double>(
      begin: 0.94,
      end: -0.16,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onWaveAnimationCompleted() {
    if (!mounted || _isFinishEventSent) {
      return;
    }

    _isFinishEventSent = true;
    context.read<SplashBloc>().add(const SplashWaveTransitionFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _violet,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: RepaintBoundary(
            child: ColoredBox(
              color: Colors.white,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final isFullyExpanded = _controller.value >= 0.999;

                  return SizedBox.expand(
                    child: isFullyExpanded
                        ? const ColoredBox(color: _violet)
                        : ClipPath(
                            clipBehavior: Clip.antiAlias,
                            clipper: _WaveClipper(
                              waveTopFactor: _waveTopFactor.value,
                            ),
                            child: const ColoredBox(color: _violet),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper({required this.waveTopFactor});

  final double waveTopFactor;

  @override
  Path getClip(Size size) {
    const double waveAmplitude = 38;
    final double waveY = size.height * waveTopFactor;

    final path = Path();
    path.moveTo(0, waveY);
    path.cubicTo(
      size.width * 0.16,
      waveY - waveAmplitude,
      size.width * 0.34,
      waveY - waveAmplitude,
      size.width * 0.5,
      waveY,
    );
    path.cubicTo(
      size.width * 0.66,
      waveY + waveAmplitude,
      size.width * 0.84,
      waveY + waveAmplitude,
      size.width,
      waveY,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) {
    return oldClipper.waveTopFactor != waveTopFactor;
  }
}
