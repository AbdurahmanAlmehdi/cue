import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AnimatablePropBase<T extends Object?, R extends Object?> {
  const AnimatablePropBase({
    this.from,
    this.to,
    this.keyframes,
    this.timing,
    this.curve,
  });

  const AnimatablePropBase.from(T this.from, {required T this.to, this.timing, this.curve}) : keyframes = null;
  const AnimatablePropBase.fixed(T value) : from = value, to = value, keyframes = null, timing = null, curve = null;
  const AnimatablePropBase.keyframes(List<Keyframe<T>> this.keyframes, {this.curve})
    : from = null,
      to = null,
      timing = null;

  final T? from;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final Timing? timing;
  final Curve? curve;

  bool get isConstant => from != null && to != null && from == to;

  R transform(ActorContext context, T value);

  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  ({Animatable<R> tween, Timing? timing}) resolveTween(ActorContext context) {
    final Animatable<R> tween;
    Timing? timing = this.timing ?? context.timing;
    if (keyframes != null) {
      assert(keyframes!.isNotEmpty, 'Keyframes list cannot be empty');
      final res = Phase.normalize<T, R>(keyframes!, (v) => transform(context, v));
      tween = buildFromPhases<R>(res.phases, (from, to) {
        return createSingleTween(transform(context, from as T), transform(context, to as T));
      });
      if (res.timing != null) {
        timing = res.timing;
      }
    } else {
      assert(from != null && to != null, 'From and to values must be provided when not using keyframes');
      if (isConstant) {
        tween = ConstantTween<R>(transform(context, from as T));
      } else {
        tween = createSingleTween(transform(context, from as T), transform(context, to as T));
      }
    }
    return (tween: tween, timing: timing);
  }

  Animatable<R> asAnimtable(ActorContext context) {
    final res = resolveTween(context);
    return applyCurves(
      res.tween,
      curve: curve ?? context.curve,
      timing: res.timing,
      isBounded: context.isBounded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AnimatablePropBase<T, R> &&
        other.from == from &&
        other.to == to &&
        listEquals(keyframes, other.keyframes);
  }

  @override
  int get hashCode => Object.hash(from, to, Object.hashAll(keyframes ?? []));
}

abstract class AnimatableProp<T> extends AnimatablePropBase<T, T> {
  const AnimatableProp({
    super.from,
    super.to,
    super.keyframes,
    super.timing,
    super.curve,
  });

  @override
  T transform(_, T value) => value;

  const AnimatableProp.from(super.from, {required super.to, super.timing, super.curve}) : super.from();
  const AnimatableProp.fixed(super.value) : super.fixed();
  const AnimatableProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();
}

class _LerpFnTween<T> extends Animatable<T> {
  final T from;
  final T to;
  final T Function(T a, T b, double t) lerpFn;

  _LerpFnTween(this.from, this.to, this.lerpFn);

  @override
  T transform(double t) => lerpFn(from, to, t);
}

class ColorProp extends AnimatableProp<Color?> {
  const ColorProp.from(Color super.from, {required Color super.to, super.timing, super.curve}) : super.from();
  const ColorProp.fixed(Color super.value) : super.fixed();
  const ColorProp.keyframes(List<Keyframe<Color>> super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Color?> createSingleTween(Color? from, Color? to) {
    if (isConstant) {
      return ConstantTween<Color?>(from);
    }
    return ColorTween(begin: from, end: to);
  }
}

class BorderRadiusProp extends AnimatablePropBase<BorderRadiusGeometry?, BorderRadius?> {
  const BorderRadiusProp.from(
    BorderRadiusGeometry super.from, {
    required BorderRadiusGeometry super.to,
    super.timing,
    super.curve,
  }) : super.from();
  const BorderRadiusProp.fixed(BorderRadiusGeometry super.value) : super.fixed();
  const BorderRadiusProp.keyframes(List<Keyframe<BorderRadiusGeometry>> super.keyframes, {super.curve})
    : super.keyframes();

  @override
  BorderRadius? transform(ActorContext context, BorderRadiusGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<BorderRadius?> createSingleTween(BorderRadius? from, BorderRadius? to) {
    if (isConstant) {
      return ConstantTween<BorderRadius?>(from);
    }
    return BorderRadiusTween(begin: from, end: to);
  }
}

class DecorationImageProp extends AnimatableProp<DecorationImage?> {
  const DecorationImageProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const DecorationImageProp.fixed(super.value) : super.fixed();
  const DecorationImageProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<DecorationImage?> createSingleTween(DecorationImage? from, DecorationImage? to) {
    if (isConstant) {
      return ConstantTween<DecorationImage?>(from);
    }
    return _LerpFnTween<DecorationImage?>(from, to, DecorationImage.lerp);
  }
}

class BoxBorderProp extends AnimatableProp<BoxBorder?> {
  const BoxBorderProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const BoxBorderProp.fixed(super.value) : super.fixed();
  const BoxBorderProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<BoxBorder?> createSingleTween(BoxBorder? from, BoxBorder? to) {
    if (isConstant) {
      return ConstantTween<BoxBorder?>(from);
    }
    return _LerpFnTween<BoxBorder?>(from, to, BoxBorder.lerp);
  }
}

class BoxShadowProp extends AnimatableProp<List<BoxShadow>?> {
  const BoxShadowProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const BoxShadowProp.fixed(super.value) : super.fixed();
  const BoxShadowProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<List<BoxShadow>?> createSingleTween(List<BoxShadow>? from, List<BoxShadow>? to) {
    if (isConstant) {
      return ConstantTween<List<BoxShadow>?>(from);
    }
    return _LerpFnTween<List<BoxShadow>?>(from, to, BoxShadow.lerpList);
  }
}

class GradientProp extends AnimatableProp<Gradient?> {
  const GradientProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const GradientProp.fixed(super.value) : super.fixed();
  const GradientProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Gradient?> createSingleTween(Gradient? from, Gradient? to) {
    if (isConstant) {
      return ConstantTween<Gradient?>(from);
    }
    return _LerpFnTween<Gradient?>(from, to, Gradient.lerp);
  }
}
