part of 'act.dart';

class ScaleEffect extends TweenEffect<double> {
  const ScaleEffect({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
    this.alignment,
  });

  final AlignmentGeometry? alignment;

  const ScaleEffect.up({
    super.from = 0.0,
    super.curve,
    super.timing,
    this.alignment,
  }) : super(to: 1.0);

  const ScaleEffect.down({
    super.to = 0.0,
    super.curve,
    super.timing,
    this.alignment,
  }) : super(from: 1.0);

  const ScaleEffect.keyframes(super.keyframes, {super.curve, this.alignment})
    : super.keyframes();

  @override
  Widget apply(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final effectiveAlignment =
        alignment?.resolve(Directionality.maybeOf(context)) ?? Alignment.center;
    return ScaleTransition(
      scale: animation,
      alignment: effectiveAlignment,
      child: child,
    );
  }
}
