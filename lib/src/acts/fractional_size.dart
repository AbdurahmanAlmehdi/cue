part of 'base/act.dart';

class FractionalSizeAct extends TweenAct<Size> {
  const FractionalSizeAct({
    super.from = Size.zero,
    super.to = Size.zero,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    this.alignment = Alignment.center,
  });

  const FractionalSizeAct.keyframes(
    super.keyframes, {
    super.curve,
    super.reverseCurve,
    this.alignment = Alignment.center,
  }) : super.keyframes();

  final AlignmentGeometry alignment;

  @override
  Widget apply(BuildContext context, Animation<Size> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: animation.value.width,
          heightFactor: animation.value.height,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}
