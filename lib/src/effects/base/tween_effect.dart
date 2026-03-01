import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class TweenEffectBase<T extends Object?, R extends Object?> extends AnimatablePropBase<T, R>
    implements Effect {
  const TweenEffectBase({
    required T super.from,
    required T super.to,
    super.curve,
    super.timing,
  }) : super(keyframes: null);

  const TweenEffectBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.curve,
  }) : super(
         from: null,
         to: null,
         keyframes: keyframes,
       );

  @internal
  const TweenEffectBase.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  });

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

abstract class TweenEffect<T extends Object?> extends TweenEffectBase<T, T> {
  const TweenEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  @override
  T transform(_, T value) => value;

  const TweenEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const TweenEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();
}
