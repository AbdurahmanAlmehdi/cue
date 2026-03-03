import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class TweenActBase<T extends Object?, R extends Object?> extends AnimatablePropBase<T, R> implements Act {
  const TweenActBase({
    required T super.from,
    required T super.to,
    super.curve,
    super.timing,
  }) : super(keyframes: null);

  const TweenActBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.curve,
  }) : super(
         from: null,
         to: null,
         keyframes: keyframes,
       );

  @internal
  const TweenActBase.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  });

  @override
  List<Act> get flattened => [this];

  @nonVirtual
  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is Animation<R>,
      'Expected animation of type Animation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as Animation<R>, child);
  }

  Widget apply(BuildContext context, Animation<R> animation, Widget child);

  @override
  Animation<R> buildAnimation(Animation<double> driver, ActorContext context) {
    final tweenRes = resolveTween(context);

    final tween = tweenRes.tween;
    if (tween is ConstantTween<R>) {
      // todo: rethink what status should the animation be in
      return AlwaysStoppedAnimation(tween.begin as R);
    }

    final animatable = applyCurves(
      tween,
      curve: context.curve,
      timing: tweenRes.timing,
      isBounded: context.isBounded,
    );

    Animatable<R>? reverseAnimatable;
    if (context.reverseCurve != null || context.reverseTiming != null) {
      reverseAnimatable = applyCurves<R>(
        tween,
        curve: context.reverseCurve,
        timing: context.reverseTiming,
        isBounded: context.isBounded,
      );
    }

    return switch (context.role) {
      ActorRole.both =>
        reverseAnimatable == null
            ? driver.drive(animatable)
            : DualAnimation(
                parent: driver,
                forward: animatable,
                reverse: reverseAnimatable,
              ),
      ActorRole.forward => ForwardOrStoppedAnimation(driver).drive(animatable),
      ActorRole.reverse => ReverseOrStoppedAnimation(driver).drive(animatable),
    };
  }
}

abstract class TweenAct<T extends Object?> extends TweenActBase<T, T> {
  const TweenAct({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  @override
  T transform(_, T value) => value;

  const TweenAct.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const TweenAct.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();
}
