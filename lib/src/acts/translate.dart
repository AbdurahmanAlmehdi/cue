part of 'act.dart';

abstract class Translate extends Act {
  const factory Translate({
    Offset begin,
    Offset end,
    Curve? curve,
    Timing? timing,
  }) = _TranslateOffset;

  const factory Translate.keyframes(List<Keyframe<Offset>> keyframes, {Curve? curve}) = _TranslateOffset.keyframes;

  const factory Translate.x({double begin, double end, Curve? curve, Timing? timing}) = _TranslateX;

  const factory Translate.keyframesX(List<Keyframe<double>> keyframes, {Curve? curve}) = _TranslateX.keyframes;

  const factory Translate.y({double begin, double end, Curve? curve, Timing? timing}) = _TranslateY;

  const factory Translate.keyframesY(List<Keyframe<double>> keyframes, {Curve? curve}) = _TranslateY.keyframes;
}

class _TranslateOffset extends TweenAct<Offset> implements Translate {
  const _TranslateOffset({
    super.begin = Offset.zero,
    super.end = Offset.zero,
    super.curve,
    super.timing,
  });

  const _TranslateOffset.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return _TranslateTransition(
      position: build(context),
      transformHitTests: true,
      offsetBuilder: (v) => v,
      child: child,
    );
  }
}

class _TranslateY extends TweenAct<double> implements Translate {
  const _TranslateY({
    super.begin = 0,
    super.end = 0,
    super.curve,
    super.timing,
  });

  const _TranslateY.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return _TranslateTransition(
      position: build(context),
      transformHitTests: true,
      offsetBuilder: (value) => Offset(0, value),
      child: child,
    );
  }
}

class _TranslateX extends TweenAct<double> implements Translate {
  const _TranslateX({
    super.begin = 0,
    super.end = 0,
    super.curve,
    super.timing,
  });

  const _TranslateX.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return _TranslateTransition(
      position: build(context),
      transformHitTests: true,
      offsetBuilder: (value) => Offset(value, 0),
      child: child,
    );
  }
}

class _TranslateTransition<T> extends AnimatedWidget {
  final Widget child;
  final Animation<T> position;
  final bool transformHitTests;
  final Offset Function(T value) offsetBuilder;

  const _TranslateTransition({
    required this.child,
    required this.position,
    this.transformHitTests = true,
    required this.offsetBuilder,
  }) : super(listenable: position);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      transformHitTests: transformHitTests,
      offset: offsetBuilder(position.value),
      child: child,
    );
  }
}
