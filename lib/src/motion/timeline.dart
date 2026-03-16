import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

abstract class CueTimeline<Driver extends CueAnimationDriver> extends Simulation {
  CueAnimationDriver driverFor(DriverConfig config);
  void prepare({required bool forward});
  void release(Driver anim);

  final Map<DriverConfig, Driver> drivers;

  CueTimeline(this.drivers);

  Driver buildDriver(DriverConfig config);

  void addOnPrepareListener(ValueChanged<bool> listener);
  CueMotion get mainMotion;

  Driver get mainDriver;
}

abstract class CuePlaybackTimelineBase<Driver extends CueAnimationDriver> extends CueTimeline<Driver> {
  @override
  void addOnPrepareListener(ValueChanged<bool> listener) {
    _onPrapaerNotifier.addEventListener(listener);
  }

  final _onPrapaerNotifier = EventNotifier<bool>();

  CuePlaybackTimelineBase(Driver main)
    : super({
        DriverConfig(
          motion: main.motion,
          reverseMotion: main.reverseMotion,
        ): main,
      });

  double _lastT = 0.0;

  @override
  Driver get mainDriver => drivers.values.first;

  @override
  CueAnimationDriver driverFor(DriverConfig config) {
    final mergedConfig = drivers.keys.first.merge(config);
    final animation = drivers.putIfAbsent(mergedConfig, () => buildDriver(mergedConfig));
    // if already animating eagerly prepare the new animation to match the current progress and velocity
    if (mainDriver.isAnimating) {
      animation.prepare(
        forward: mainDriver.isForwardOrCompleted,
        velocity: mainDriver.velocity,
      );
      _onPrapaerNotifier.fireEvent(mainDriver.isForwardOrCompleted);
    }
    return animation;
  }

  @override
  void release(Driver anim) {}

  @override
  void prepare({required bool forward}) {
    _onPrapaerNotifier.fireEvent(forward);
    _lastT = 0.0;
    for (final anim in drivers.values) {
      anim.prepare(forward: forward);
    }
  }

  @override
  double x(double time) {
    final dt = time - _lastT;
    _lastT = time;
    if (dt > 0) {
      for (final anim in drivers.values) {
        anim.advance(dt);
      }
    }
    return mainDriver.value;
  }

  @override
  double dx(double time) => mainDriver.velocity;

  @override
  bool isDone(double time) => drivers.values.every((anim) => anim.isDone);

  @override
  CueMotion get mainMotion => drivers.keys.first.motion;
}

abstract class CueAnimationDriver extends Animation<double> with AnimationLocalStatusListenersMixin {
  void prepare({required bool forward, double? velocity});

  CueMotion get motion;
  CueMotion? get reverseMotion;
  Duration get delay;
  Duration get reverseDelay;

  void advance(double progress);

  bool get isDone;

  double get velocity;

  int get phase;

  @override
  void didRegisterListener() {}

  @override
  void didUnregisterListener() {}

  bool get isReverseOrDismissed => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
}

class CuePlaybackTimeline extends CuePlaybackTimelineBase<CuePlaypackDriver> {
  CuePlaybackTimeline(super.drivers);

  @override
  CuePlaypackDriver<CueMotion> buildDriver(DriverConfig config) {
    return CuePlaypackDriver(
      config.motion,
      reverseMotion: config.reverseMotion,
      delay: config.delay ?? Duration.zero,
      reverseDelay: config.reverseDelay ?? Duration.zero,
      reverseType: config.reverseType,
    );
  }
}

class CueProgressTimeline extends CuePlaybackTimelineBase<CueSeekableAnimationsDriver> {
  CueProgressTimeline(double initialProgress, {AnimationStatus status = AnimationStatus.forward})
    : super(
        CueSeekableAnimationsDriver(
          LinearSimulationMotion(),
          delay: Duration.zero,
          reverseDelay: Duration.zero,
        )..seek(initialProgress, status: status),
      );

  @override
  CueSeekableAnimationsDriver buildDriver(DriverConfig config) {
    return CueSeekableAnimationsDriver(
      config.motion,
      reverseMotion: config.reverseMotion,
      delay: config.delay ?? Duration.zero,
      reverseDelay: config.reverseDelay ?? Duration.zero,
    )..seek(mainDriver.value, status: mainDriver.status);
  }

  double get progress => _progress;
  double _progress = 0.0;

  void seek(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    if (_progress == progress && mainDriver.status == status) return;
    _progress = progress;
    for (final driver in drivers.values) {
      driver.seek(progress, status: status);
    }
  }
}

// class ProgressTimeline extends CueAnimationDriver with AnimationLocalListenersMixin implements CueTimeline {
//   double _value;
//   AnimationStatus _status;

//   final ValueChanged<ProgressTimeline>? onUpdate;

//   @override
//   void addOnPrepareListener(ValueChanged<bool> listener) {
//     _willAnimateNotifer.addEventListener(listener);
//   }

//   final _willAnimateNotifer = EventNotifier<bool>();

//   ProgressTimeline(
//     this._value, {
//     AnimationStatus status = AnimationStatus.completed,
//     this.onUpdate,
//   }) : _status = status;

//   final Map<DriverConfig, CueSeekableAnimationsDriver> _animations = {};

//   final _mainConfig = const DriverConfig(motion: LinearSimulationMotion());

//   Duration get totalDuration {
//     Duration maxDuration = _mainConfig.motion.duration;
//     for (final animation in _animations.values) {
//       final duration = Duration(
//         microseconds: (animation.motion.durationSeconds * Duration.microsecondsPerSecond).round(),
//       );
//       if (duration > maxDuration) {
//         maxDuration = duration;
//       }
//     }
//     return maxDuration;
//   }

//   @override
//   CueAnimationDriver driverFor(DriverConfig config) {
//     final key = config.copyWith(
//       reverseMotion: config.reverseMotion ?? _mainConfig.motion,
//       // ignore delay for progress-based animations since the progress itself determines the timing
//       // delay: .zero,
//       // reverseDelay: .zero,
//     );
//     if (key == _mainConfig) {
//       return this;
//     }
//     final animation = _animations.putIfAbsent(
//       key,
//       () => CueSeekableAnimationsDriver(
//         key.motion,
//         reverseMotion: key.reverseMotion,
//         delay: key.delay ?? Duration.zero,
//         reverseDelay: key.reverseDelay ?? Duration.zero,
//       ),
//     );
//     onUpdate?.call(this);
//     return animation;
//   }

//   @override
//   double get value => _value;

//   @override
//   void prepare({required bool forward, double? velocity}) {
//     _willAnimateNotifer.fireEvent(forward);
//     // no-op
//   }

//   @override
//   void release(CueAnimationDriver anim) {
//     // TODO: implement release
//   }

//   @override
//   AnimationStatus get status => _status;

//   @override
//   void advance(double value, {AnimationStatus status = AnimationStatus.forward}) {
//     final valueChanged = _value != value;
//     final statusChanged = _status != status;

//     if (!valueChanged && !statusChanged) return;
//     _value = value;
//     _status = status;

//     if (statusChanged) notifyStatusListeners(status);
//     if (valueChanged) {
//       for (final anim in _animations.values) {
//         anim.advance(value, status: status);
//       }
//       notifyListeners();
//     }
//   }

//   @override
//   bool get isDone => _status.isCompleted || _status.isDismissed;

//   @override
//   double get velocity => 0.0;

//   @override
//   int get phase => 0;

//   @override
//   CueMotion get mainMotion => _mainConfig.motion;
// }

class CuePlaypackDriver<Motion extends CueMotion> extends CueAnimationDriver with AnimationLocalListenersMixin {
  @override
  final Motion motion;
  @override
  final Motion? reverseMotion;
  @override
  final Duration delay;
  @override
  final Duration reverseDelay;
  final ReverseBehaviorType reverseType;

  CueSimulation? _sim;
  double _value = 0.0;
  double _localT = 0.0;
  double _delaySeconds = 0.0;
  bool _done = true; // idle until prepared

  CuePlaypackDriver(
    this.motion, {
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  @override
  double get value => _value;

  @override
  AnimationStatus get status {
    return switch ((_forward, _done)) {
      (true, true) => AnimationStatus.completed,
      (true, false) => AnimationStatus.forward,
      (false, true) => AnimationStatus.dismissed,
      (false, false) => AnimationStatus.reverse,
    };
  }

  bool _forward = true;

  @override
  void prepare({required bool forward, double? velocity}) {
    if (forward && reverseType.isExclusive) {
      // this drive should only drive reverse animation
      _done = true;
      return;
    }
    if (!forward && reverseType.isNone) {
      // this drive should not drive reverse animation
      _done = true;
      return;
    }
    _forward = forward;

    final active = forward ? motion : (reverseMotion ?? motion);

    int phase = _sim?.phase ?? 0;
    double progress = _sim?.progress ?? _value;

    if (reverseType.isExclusive) {
      _value = 1.0;
      progress = 1.0;
      phase = motion.totalPhases - 1;
    } else if (forward && reverseType.isNone) {
      _value = 0.0;
      progress = 0.0;
      phase = 0;
    }
    _sim = active.build(forward, phase, progress, velocity ?? this.velocity);
    _delaySeconds = (forward ? delay : (reverseDelay)).inMicroseconds / Duration.microsecondsPerSecond;
    _localT = 0.0;
    _done = false;
    notifyStatusListeners(status);
  }

  @override
  void advance(double progress) {
    if (_done || _sim == null) return;
    _localT += progress;
    final t = _localT - _delaySeconds;
    if (t < 0) return; // still in delay

    if (_sim!.isDone(t)) {
      _value = _sim!.x(t);
      _done = true;
      notifyListeners();
      notifyStatusListeners(_forward ? AnimationStatus.completed : AnimationStatus.dismissed);
      return;
    }
    _value = _sim!.x(t);
    notifyListeners();
  }

  @override
  bool get isDone => _done;

  @override
  double get velocity {
    if (_sim == null) return 0.0;
    final t = (_localT - _delaySeconds).clamp(0.0, double.infinity);
    return _sim!.dx(t);
  }

  @override
  int get phase => _sim?.phase ?? 0;
}

class CueSeekableAnimationsDriver extends CuePlaypackDriver<BakedMotion> {
  CueSeekableAnimationsDriver(
    CueMotion motion, {
    CueMotion? reverseMotion,
    Duration delay = Duration.zero,
    Duration reverseDelay = Duration.zero,
  }) : super(
         motion.bake(),
         reverseMotion: reverseMotion?.bake(),
         delay: delay,
         reverseDelay: reverseDelay,
       );

  void seek(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    final activeMotion = status.isForwardOrCompleted ? motion : (reverseMotion ?? motion);
    final value = activeMotion.valueAt(progress);
    final valueChanged = _value != value;
    final statusChanged = status != this.status;
    if (!valueChanged && !statusChanged) return;
    _value = value;
    _forward = status.isForwardOrCompleted;
    _done = status.isCompleted || status.isDismissed;
    if (statusChanged) notifyStatusListeners(status);
    notifyListeners();
  }
}

// class CueSeekableAnimationsDriverx extends CueAnimationDriver with AnimationLocalListenersMixin {
//   final BakedMotion motion;
//   final BakedMotion? reverseMotion;
//   final Duration delay;
//   final Duration reverseDelay;

//   double _value = 0.0;

//   CueSeekableAnimationsDriver(
//     CueMotion motion, {
//     CueMotion? reverseMotion,
//     this.delay = Duration.zero,
//     this.reverseDelay = Duration.zero,
//   }) : motion = motion.bake(),
//        reverseMotion = reverseMotion?.bake();

//   @override
//   double get value => _value;

//   AnimationStatus _status = AnimationStatus.completed;

//   @override
//   AnimationStatus get status => _status;

//   @override
//   void prepare({required bool forward, double? velocity}) {
//     // no-op we're using pre-baked values
//   }

//   @override
//   void advance(double progress, {AnimationStatus status = AnimationStatus.forward}) {
//     final activeMotion = _status.isForwardOrCompleted ? motion : (reverseMotion ?? motion);
//     final value = activeMotion.valueAt(progress);
//     final valueChanged = _value != value;
//     final statusChanged = _status != status;
//     if (!valueChanged && !statusChanged) return;
//     _value = value;
//     _status = status;
//     if (statusChanged) notifyStatusListeners(status);
//     notifyListeners();
//   }

//   @override
//   bool get isDone => false;

//   @override
//   double get velocity => 0.0;

//   @override
//   int get phase => 0;
// }

class DriverConfig {
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final Duration? delay;
  final Duration? reverseDelay;
  final ReverseBehaviorType reverseType;

  const DriverConfig({
    required this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  DriverConfig merge(DriverConfig other) {
    return copyWith(
      motion: other.motion,
      reverseMotion: other.reverseMotion,
      delay: other.delay,
      reverseDelay: other.reverseDelay,
      reverseType: other.reverseType,
    );
  }

  DriverConfig copyWith({
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
    ReverseBehaviorType? reverseType,
  }) {
    return DriverConfig(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      delay: delay ?? this.delay,
      reverseDelay: reverseDelay ?? this.reverseDelay,
      reverseType: reverseType ?? this.reverseType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverConfig &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.delay == delay &&
        other.reverseType == reverseType &&
        other.reverseDelay == reverseDelay;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, delay, reverseDelay, reverseType);
}
