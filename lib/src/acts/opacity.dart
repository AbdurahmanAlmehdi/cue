part of 'base/act.dart';

class OpacityAct extends TweenAct<double> {
  const OpacityAct({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
  });

  const OpacityAct.fadeIn({super.from = 0.0, super.to = 1.0, super.curve, super.timing});
  const OpacityAct.fadeOut({super.from = 1.0, super.to = 0.0, super.curve, super.timing});

  const OpacityAct.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
