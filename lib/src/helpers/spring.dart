// holds default values for spring simulation
import 'package:flutter/physics.dart';

const double _kStandardIosStiffness = 522.35;
const double _kStandardIosDamping = 45.7099552;
const Tolerance _kStandardIosTolerance = Tolerance(velocity: 0.03);

class Spring extends SpringSimulation {
  final SpringDescription _springDesc;
  final double _start;
  final double _end;
  final double _velocity;
  final bool _snapToEnd;

  Spring(
    super.spring,
    super.start,
    super.end,
    super.velocity, {
    super.tolerance,
    super.snapToEnd,
  }) : _springDesc = spring,
       _start = start,
       _end = end,
       _velocity = velocity,
       _snapToEnd = snapToEnd;

  Spring copyWith({
    SpringDescription? spring,
    double? start,
    double? end,
    double? velocity,
    Tolerance? tolerance,
    bool? snapToEnd,
  }) {
    return Spring(
      spring ?? _springDesc,
      start ?? _start,
      end ?? _end,
      velocity ?? _velocity,
      snapToEnd: snapToEnd ?? _snapToEnd,
      tolerance: tolerance ?? this.tolerance,
    );
  }

  Spring withDirection(bool forward) {
    final start = forward ? 0.0 : 1.0;
    if (start == _start) return this;
    return copyWith(
      start: start,
      end: forward ? 1.0 : 0.0,
    );
  }

  factory Spring.iosDefault({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: _kStandardIosStiffness,
        damping: _kStandardIosDamping,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: _kStandardIosTolerance,
      snapToEnd: true,
    );
  }

  factory Spring.smooth({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 157.91,
        damping: 25.13,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.snappy({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 246.74,
        damping: 26.70,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.bouncy({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 157.91,
        damping: 15.08,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.interactive({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 1754.17,
        damping: 72.11,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.gentle({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 61.69,
        damping: 15.71,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.stiff({
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription(
        mass: 1.0,
        stiffness: 438.65,
        damping: 41.89,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }

  factory Spring.withDurationAndBounce({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
    double start = 0.0,
    double end = 1.0,
    double? velocity,
  }) {
    return Spring(
      SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      start,
      end,
      velocity ?? 0.0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }
}
