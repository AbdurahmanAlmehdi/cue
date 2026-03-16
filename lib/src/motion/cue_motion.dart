import 'dart:ui';

import 'package:flutter/material.dart';
import 'spring_motion.dart';

abstract class CueMotion {
  const CueMotion();

  BakedMotion bake({int samples = 60, Duration delay = Duration.zero});

  Duration get duration;

  int get totalPhases => 1;

  CueSimulation build(bool forward, int phase, double progress, double? velocity);

  bool get isTimed => this is TimedMotion;
  bool get isSimulation => this is SimulationMotion;

  const factory CueMotion.curved(
    Duration duration, {
    required Curve curve,
  }) = TimedMotion.curved;

  const factory CueMotion.linear(Duration duration) = TimedMotion;

  static const jump = TimedMotion(Duration.zero);

  static const CueMotion defaultDuration = TimedMotion(
    Duration(milliseconds: 300),
  );

  factory CueMotion.spring({
    Duration duration,
    double bounce,
  }) = Spring;

  const factory CueMotion.smooth({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.smooth;

  const factory CueMotion.gentle({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.gentle;

  const factory CueMotion.iosDefaultSpring({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.iosDefault;

  const factory CueMotion.bouncy({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.bouncy;

  const factory CueMotion.wobbly({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.wobbly;

  const factory CueMotion.stiff({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.stiff;
}

class TimedMotion extends CueMotion {
  @override
  final Duration duration;
  final Curve? curve;
  const TimedMotion(this.duration) : curve = null;
  const TimedMotion.curved(this.duration, {required Curve this.curve});

  @override
  BakedMotion bake({int samples = 60, Duration delay = Duration.zero}) {
    assert(samples >= 2, 'samples must be at least 2');
    final motionSeconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    final activeCurve = curve ?? Curves.linear;

    final delaySamples = BakedMotion.backDelay(
      totalSamples: samples,
      motionSeconds: motionSeconds,
      delay: delay,
    );
    final animCount = samples - delaySamples.length;

    final animated = List<double>.generate(animCount, (i) {
      final t = animCount == 1 ? 1.0 : i / (animCount - 1);
      return activeCurve.transform(t);
    });

    final delaySeconds = delay.inMicroseconds / Duration.microsecondsPerSecond;

    return BakedMotion(
      motion: this,
      samples: [...delaySamples, ...animated],
      durationSeconds: motionSeconds + delaySeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedMotion && runtimeType == other.runtimeType && duration == other.duration && curve == other.curve;

  @override
  int get hashCode => duration.hashCode ^ curve.hashCode;

  @override
  CueSimulation build(bool forward, int phase, double progress, double? velocity) {
    return CurvedSimulation(
      duration: duration,
      curve: curve ?? Curves.linear,
      from: progress,
      to: forward ? 1.0 : 0.0,
    );
  }
}

mixin CueSimulation on Simulation {
  int get phase => 0;

  double get progress;
}

class CurvedSimulation extends Simulation with CueSimulation {
  final double _durationSeconds;
  final Curve _curve;
  final double _from;
  final double _to;

  double _progress = 0.0;

  @override
  double get progress => _progress;

  CurvedSimulation({
    required Duration duration,
    required Curve curve,
    required double from,
    required double to,
  }) : _durationSeconds = duration.inMicroseconds / Duration.microsecondsPerSecond,
       _curve = curve,
       _from = from,
       _to = to;

  @override
  double x(double t) {
    final progress = (t / _durationSeconds).clamp(0.0, 1.0);
    return _progress = _from + (_to - _from) * _curve.transform(progress);
  }

  @override
  double dx(double t) {
    final double epsilon = tolerance.time;
    return (x(t + epsilon) - x(t - epsilon)) / (2 * epsilon);
  }

  @override
  bool isDone(double t) => t >= _durationSeconds;
}

abstract class SimulationMotion<S extends CueSimulation> extends CueMotion {
  const SimulationMotion();
}

extension DurationExtension on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get sec => Duration(seconds: this);
  Duration get m => Duration(minutes: this);
}

class SegmentedMotion extends CueMotion {
  final List<CueMotion> motions;
  const SegmentedMotion(this.motions);

  @override
  int get totalPhases => motions.length;

  @override
  BakedMotion bake({int samples = 60, Duration delay = Duration.zero}) {
    assert(samples >= 2, 'samples must be at least 2');
    final segmentCount = motions.length;
    final samplesPerSegment = (samples / segmentCount).ceil();

    final bakedSegments = motions.map((m) => m.bake(samples: samplesPerSegment)).toList();

    final motionSamples = bakedSegments.expand((b) => b.samples).toList();
    final motionSeconds = bakedSegments.fold<double>(
      0.0,
      (sum, b) => sum + b.durationSeconds,
    );

    final delaySamples = BakedMotion.backDelay(
      totalSamples: motionSamples.length,
      motionSeconds: motionSeconds,
      delay: delay,
    );

    final delaySeconds = delay.inMicroseconds / Duration.microsecondsPerSecond;

    return BakedMotion(
      motion: this,
      samples: [...delaySamples, ...motionSamples],
      durationSeconds: motionSeconds + delaySeconds,
    );
  }

  @override
  CueSimulation build(bool forward, int phase, double progress, double? velocity) {
    return SegmentedSimulation(
      motions: motions,
      forward: forward,
      initialPhase: phase,
      initialProgress: progress,
      initialVelocity: velocity ?? 0.0,
    );
  }

  @override
  Duration get duration => motions.fold(Duration.zero, (acc, a) => acc + a.duration);
}

class SegmentedSimulation extends Simulation with CueSimulation {
  final List<CueMotion> _motions;
  final bool _forward;

  int _phase;
  double _phaseStartTime = 0;
  late CueSimulation _current;
  double _progress = 0.0;

  @override
  double get progress => _progress;

  @override
  int get phase => _phase;

  SegmentedSimulation({
    required List<CueMotion> motions,
    required bool forward,
    required double initialVelocity,
    int initialPhase = 0,
    double initialProgress = 0,
  }) : _motions = motions,
       _forward = forward,
       _phase = initialPhase {
    _current = motions[initialPhase].build(
      forward,
      initialPhase,
      initialProgress,
      initialVelocity,
    );
  }

  @override
  double x(double time) {
    _advanceIfNeeded(time);
    return _progress = _current.x(time - _phaseStartTime);
  }

  @override
  double dx(double time) {
    _advanceIfNeeded(time);
    return _current.dx(time - _phaseStartTime);
  }

  @override
  bool isDone(double time) {
    if (_forward) {
      return _phase >= _motions.length - 1 && _current.isDone(time - _phaseStartTime);
    } else {
      return _phase <= 0 && _current.isDone(time - _phaseStartTime);
    }
  }

  void _advanceIfNeeded(double time) {
    final localTime = time - _phaseStartTime;
    final canAdvance = _forward ? _phase < _motions.length - 1 : _phase > 0;
    if (canAdvance && _current.isDone(localTime)) {
      double exitVelocity = _current.dx((localTime - 0.016).clamp(0.0, double.infinity));
      // Negate velocity when reversing
      if (!_forward) {
        exitVelocity = -exitVelocity;
      }
      _phaseStartTime = time;
      _forward ? _phase++ : _phase--;
      final initialProgress = _forward ? 0.0 : 1.0;
      _current = _motions[_phase].build(_forward, 0, initialProgress, exitVelocity);
    }
  }
}

class BakedMotion extends CueMotion {
  final List<double> samples;
  final double durationSeconds;
  final CueMotion motion;
  final double Function(double progress, List<double> samples) valueGetter;

  const BakedMotion({
    required this.motion,
    required this.samples,
    required this.durationSeconds,
    this.valueGetter = _defaultValueGetter,
  });

  static List<double> backDelay({
    required int totalSamples,
    required double motionSeconds,
    required Duration delay,
    double holdValue = 0.0,
  }) {
    final delaySeconds = delay.inMicroseconds / Duration.microsecondsPerSecond;
    if (totalSamples < 2 || delaySeconds <= 0) return const [];
    final totalSeconds = motionSeconds + delaySeconds;
    if (totalSeconds <= 0) return const [];
    final count = (((totalSamples - 1) * (delaySeconds / totalSeconds)).round()).clamp(0, totalSamples - 2);
    return List<double>.filled(count, holdValue);
  }

  static double _defaultValueGetter(double progress, List<double> samples) {
    final scaled = progress * (samples.length - 1);
    final lo = samples[scaled.floor()];
    final hi = samples[scaled.ceil()];
    return lerpDouble(lo, hi, scaled - scaled.floor())!;
  }

  double valueAt(double progress) => valueGetter(progress, samples);

  @override
  BakedMotion bake({int samples = 60, Duration delay = Duration.zero}) => this;

  @override
  CueSimulation build(bool forward, int phase, double progress, double? velocity) {
    return motion.build(forward, phase, progress, velocity);
  }

  @override
  Duration get duration => motion.duration;
}
