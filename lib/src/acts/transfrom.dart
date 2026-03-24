part of 'base/act.dart';

class TransformAct extends TweenAct<Matrix4> {
  
  @override
  final ActKey key = const ActKey('Transform');

   TransformAct({
     Matrix4? from,
    required super.to,
    super.motion,
    super.reverse,
    this.alignment,
    this.origin,
  }) : super.tween(from: from ?? Matrix4.identity());

  final AlignmentGeometry? alignment;
  final Offset? origin;

   TransformAct.keyframed({
    required super.frames,  
    super.reverse,
    this.alignment,
    this.origin,
  }) : super.keyframed(from: Matrix4.identity());

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: alignment,
          origin: origin,
          child: child,
        );
      },
    );
  }
}
