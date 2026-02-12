part of 'actor_impl.dart';

abstract class Actor extends Widget {
  const factory Actor({
    Key? key,
    required List<Act> acts,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ActorBase;

  const factory Actor.rotate({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = RotateActorFactory;

  const factory Actor.rotateTurns({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = RotateActorFactory.turns;

  const factory Actor.scale({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry? alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ScaleActorFactory;

  const factory Actor.fade({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = FadeActorFactory;

  const factory Actor.slide({
    Key? key,
    required Offset from,
    required Offset to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = SlideActorFactory;

  const factory Actor.slideX({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = SlideActorFactory.x;

  const factory Actor.slideY({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = SlideActorFactory.y;

  const factory Actor.align({
    Key? key,
    AlignmentGeometry? from,
    AlignmentGeometry? to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = AlignActorFactory;

  const factory Actor.resize({
    Key? key,
    required Size from,
    required Size to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ResizeActorFactory;

  const factory Actor.resizeFractionally({
    Key? key,
    required Size from,
    required Size to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ResizeActorFactory.fractionally;

  const factory Actor.blur({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = BlurActorFactory;

  const factory Actor.inset({
    Key? key,
    required EdgeInsetsGeometry from,
    required EdgeInsetsGeometry to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = InsetActorFactory;

  const factory Actor.translate({
    Key? key,
    required Offset from,
    required Offset to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = TranslateActorFactory;

  const factory Actor.translateX({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = TranslateActorFactory.x;

  const factory Actor.translateY({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = TranslateActorFactory.y;

  const factory Actor.clipReveal({
    Key? key,
    Size fromSize,
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ClipRevealActorFactory;

  const factory Actor.clipRevealHorizontal({
    Key? key,
    double from,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ClipRevealActorFactory.horizontal;

  const factory Actor.clipRevealVertical({
    Key? key,
    double from,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
    BoxOverflow overflow,
  }) = ClipRevealActorFactory.vertical;
}
