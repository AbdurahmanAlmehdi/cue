part of 'base/act.dart';

class BlurAct extends TweenAct<double> {
  const BlurAct({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
    super.reverse,
  });

  const BlurAct.keyframes(super.keyframes, {super.curve, super.reverse}) : super.keyframes();

  const BlurAct.focus({
    super.from = 10.0,
    super.to = 0.0,
    super.curve,
    super.timing,
    super.reverse,
  });

  const BlurAct.unfocus({
    super.from = 0.0,
    super.to = 10.0,
    super.curve,
    super.timing,
    super.reverse,
  });

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}

class BackdropBlurAct extends TweenAct<double> {
  const BackdropBlurAct({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
    super.reverse,
    this.blendMode = BlendMode.srcOver,
  });

  final BlendMode blendMode;

  const BackdropBlurAct.keyframes(
    super.keyframes, {
    super.curve,
    super.reverse,
    this.blendMode = BlendMode.srcOver,
  }) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return BackdropFilter(
          blendMode: blendMode,
          filter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}
