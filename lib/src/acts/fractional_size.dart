part of 'base/act.dart';

class FractionalSizeAct extends AnimtableAct<FractionalSize, FractionalSize> {
  @override
  final ActKey key = const ActKey('FractionalSize');

  final AnimatableValue<double>? widthFactor;
  final AnimatableValue<double>? heightFactor;
  final AnimatableValue<AlignmentGeometry>? alignment;
  final Keyframes<FractionalSize>? frames;

  const FractionalSizeAct({
    super.motion,
    super.delay,
    this.widthFactor,
    this.heightFactor,
    this.alignment = const AnimatableValue.fixed(Alignment.center),
    ReverseBehavior<FractionalSize> super.reverse = const ReverseBehavior.mirror(),
  }) : frames = null;

  const FractionalSizeAct.keyframed({
    required Keyframes<FractionalSize> this.frames,
    super.delay,
    ReverseBehavior<FractionalSize> super.reverse = const ReverseBehavior.mirror(),
  }) : widthFactor = null,
       heightFactor = null,
       alignment = null;

  @override
  Widget apply(BuildContext context, Animation<FractionalSize> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final props = animation.value;
        return FractionallySizedBox(
          widthFactor: props.widthFactor,
          heightFactor: props.heightFactor,
          alignment: props.alignment ?? Alignment.center,
          child: child,
        );
      },
    );
  }

  @override
  (CueAnimtable<FractionalSize>, CueAnimtable<FractionalSize>?) buildTweens(ActContext context) {
    final builder = TweensBuildHelper<FractionalSize>(
      from: FractionalSize(
        widthFactor: widthFactor?.from,
        heightFactor: heightFactor?.from,
        alignment: alignment?.from,
      ),
      to: FractionalSize(
        widthFactor: widthFactor?.to,
        heightFactor: heightFactor?.to,
        alignment: alignment?.to,
      ),
      frames: frames,
      reverse: reverse,
      tweenBuilder: (from, to) => _FractionalSizeTween(begin: from, end: to),
    );
    return builder.buildTweens(context);
  }

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: reverse,
      frames: frames,
    );
  }
}

class FractionalSize {
  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry? alignment;

  FractionalSize({this.widthFactor, this.heightFactor, this.alignment});

  static FractionalSize lerp(FractionalSize a, FractionalSize b, double t) {
    return FractionalSize(
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t),
      heightFactor: lerpDouble(a.heightFactor, b.heightFactor, t),
      alignment: AlignmentGeometry.lerp(a.alignment, b.alignment, t),
    );
  }
}

class _FractionalSizeTween extends Tween<FractionalSize> {
  _FractionalSizeTween({super.begin, super.end});

  @override
  FractionalSize lerp(double t) => FractionalSize.lerp(begin!, end!, t);
}
