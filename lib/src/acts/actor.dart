import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Actor extends StatelessWidget {
  final Curve? curve;
  final Timing? timing;
  final List<Act> acts;
  final Widget child;

  const Actor({
    super.key,
    required this.acts,
    required this.child,
    this.curve,
    this.timing,
  });

  @override
  Widget build(BuildContext context) {
    final scope = CueScope.of(context);
    Widget current = child;
    for (final effect in acts.reversed) {
      current = effect.wrapWidget(
        AnimationContext(
          buildContext: context,
          driver: scope.animation,
          timing: effect.timing ?? timing,
          curve: effect.curve ?? curve,
        ),
        current,
      );
    }
    return current;
  }
}

class TweenActor<T> extends StatefulWidget {
  final List<Keyframe<T>>? _keyframes;
  final Widget? child;
  final ValueWidgetBuilder<T> builder;
  final TweenBuilder<T>? _tweenBuilder;
  final Tween<T>? _tween;
  final Curve? curve;
  final Timing? timing;

  const TweenActor({
    super.key,
    required this.builder,
    required Tween<T> tween,
    this.curve,
    this.timing,
    this.child,
  }) : _tween = tween,
       _keyframes = null,
       _tweenBuilder = null;

  factory TweenActor.lerp({
    Key? key,
    required ValueWidgetBuilder<double> builder,
    Curve? curve,
    Timing? timing,
    Widget? child,
  }) =>
      _LerpDoubleTweenActor(
            key: key,
            builder: builder,
            curve: curve,
            timing: timing,
            child: child,
          )
          as TweenActor<T>;

  const TweenActor.keyframes({
    super.key,
    required this.builder,
    required List<Keyframe<T>> keys,
    TweenBuilder<T>? tweenBuilder,
    this.curve,
    this.child,
  }) : _tweenBuilder = tweenBuilder,
       _keyframes = keys,
       _tween = null,
       timing = null;

  @override
  State<StatefulWidget> createState() => _TweenActorState<T>();
}

class _LerpDoubleTweenActor extends TweenActor<double> {
  _LerpDoubleTweenActor({
    super.key,
    required super.builder,
    super.curve,
    super.timing,
    super.child,
  }) : super(tween: Tween<double>(begin: 0.0, end: 1.0));

  @override
  State<StatefulWidget> createState() => _TweenActorState<double>();
}

class _TweenActorState<T> extends State<TweenActor<T>> {
  late Animation<T> animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAnimation(context);
  }

  @override
  void didUpdateWidget(covariant TweenActor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._tween != widget._tween ||
        oldWidget.curve != widget.curve ||
        oldWidget.timing != widget.timing ||
        listEquals(widget._keyframes, oldWidget._keyframes)) {
      _setupAnimation(context);
    }
  }

  void _setupAnimation(BuildContext context) {
    AnimationContext animationContext = AnimationContext(
      buildContext: context,
      driver: CueScope.of(context).animation,
      timing: widget.timing,
      curve: widget.curve,
    );

    if (widget._tween case final tween?) {
      animation = TweenAct.buildFromPhases<T>(
        animationContext,
        [Phase<T>(begin: tween.begin as T, end: tween.end as T, weight: 100)],
        (_, _) => tween,
      );
      return;
    }

    final result = Phase.normalize(widget._keyframes!);
    if (result.timing != null) {
      animationContext = animationContext.copyWith(timing: result.timing);
    }
    animation = TweenAct.buildFromPhases<T>(
      animationContext,
      result.phases,
      widget._tweenBuilder ?? (begin, end) => Tween<T>(begin: begin, end: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return widget.builder(context, animation.value, widget.child);
      },
    );
  }
}

extension StaggeredActorExtension on Iterable<Widget> {
  List<Widget> stagger({required List<Act> Function(int index) acts}) {
    return [for (var i = 0; i < length; i++) Actor(acts: acts(i), child: elementAt(i))];
  }
}
