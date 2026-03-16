import 'package:equatable/equatable.dart';
import 'splash_phases.dart';

final class SplashState extends Equatable {
  final SplashPhase phase;

  const SplashState(this.phase);

  @override
  List<Object?> get props => [phase];
}
