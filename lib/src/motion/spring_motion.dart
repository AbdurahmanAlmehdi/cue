import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:flutter/widgets.dart';

const Tolerance _kDefaultTolerance = Tolerance(distance: 0.01, velocity: 0.03);

final class Spring extends SimulationMotion<CueSpringSimulation> {
  final double? mass;
  final double? stiffness;
  final double? dampingRatio;
  final Tolerance tolerance;
  final bool snapToEnd;
  final SpringDescription? _rawDesc;

  @override
  CueSpringSimulation build(SimulationBuildData data) {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    final refreshRate = view?.display.refreshRate ?? 60.0;
    return CueSpringSimulation(
      springDescription,
      data.startValue,
      data.endValue,
      data.velocity ?? 0.0,
      tolerance: tolerance,
      snapToEnd: snapToEnd,
      samplingStepSize: 1 / refreshRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Spring &&
        other.mass == mass &&
        other.stiffness == stiffness &&
        other.dampingRatio == dampingRatio &&
        other.tolerance == tolerance &&
        other._rawDesc == _rawDesc &&
        other.snapToEnd == snapToEnd;
  }

  @override
  int get hashCode {
    return Object.hash(mass, stiffness, dampingRatio, tolerance, snapToEnd, _rawDesc);
  }


  SpringDescription get springDescription {
    if (_rawDesc != null) {
      return _rawDesc;
    }
    assert(
      mass != null && stiffness != null && dampingRatio != null,
      'Either provide a raw SpringDescription or specify mass, stiffness, and dampingRatio',
    );
    return SpringDescription.withDampingRatio(
      mass: mass!,
      stiffness: stiffness!,
      ratio: dampingRatio!,
    );
  }

  const Spring.custom({
    required SpringDescription desc,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = desc,
       mass = null,
       stiffness = null,
       dampingRatio = null;

  const Spring.withDampingRatio({
    this.mass = 1.0,
    required this.stiffness,
    required double ratio,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null,
       dampingRatio = ratio;

  const Spring.smooth({
    double this.mass = 1.1,
    double this.stiffness = 522.35,
    double this.dampingRatio = 1.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.bouncy({
    double this.mass = 1.0,
    double this.stiffness = 325.0,
    double this.dampingRatio = 0.7,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.interactive({
    double this.mass = 1.0,
    double this.stiffness = 522.35,
    double this.dampingRatio = 0.86,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.snappy({
    double this.mass = 1.0,
    double this.stiffness = 1754.6,
    double this.dampingRatio = 1.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.wobbly({
    double this.mass = 1.0,
    double this.stiffness = 200.0,
    double this.dampingRatio = 0.4,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.gentle({
    double this.mass = 1.0,
    double this.stiffness = 61.69,
    double this.dampingRatio = 0.7,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  // Material
  const Spring.spatialFast({
    double this.mass = 1.0,
    double this.stiffness = 1400.0,
    double this.dampingRatio = 0.7,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.spatial({
    double this.mass = 1.0,
    double this.stiffness = 700.0,
    double this.dampingRatio = 0.8,
    this.snapToEnd = false,
    this.tolerance = _kDefaultTolerance,
  }) : _rawDesc = null;

  const Spring.spatialSlow({
    double this.mass = 1.0,
    double this.stiffness = 300.0,
    double this.dampingRatio = 0.8,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.effectFast({
    double this.mass = 1.0,
    double this.stiffness = 1400.0,
    double this.dampingRatio = 0.7,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.effect({
    double this.mass = 1.0,
    double this.stiffness = 700.0,
    double this.dampingRatio = 1.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  const Spring.effectSlow({
    double this.mass = 1.0,
    double this.stiffness = 300.0,
    double this.dampingRatio = 1.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  }) : _rawDesc = null;

  factory Spring({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
    bool snapToEnd = true,
  }) {
    return Spring.custom(
      desc: SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      snapToEnd: snapToEnd,
    );
  }
  @override
  Duration get baseDuration => Duration(milliseconds: (buildBase().duration * 1000).round());
}
