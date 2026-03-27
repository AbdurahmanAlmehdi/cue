part of 'cue.dart';

class _OnScrollVisibleCue extends Cue {
  const _OnScrollVisibleCue({
    required Key super.key,
    required super.child,
    super.debugLabel,
    this.enabled = true,
    super.acts,
  }) : super._();

  final bool enabled;

  @override
  State<StatefulWidget> createState() => _OnVisibleCueState();
}

class _OnVisibleCueState extends _CueState<_OnScrollVisibleCue> with SingleTickerProviderStateMixin {
  @override
  String get debugName => 'OnScrollVisibleCue';

  @override
  CueTimeline get timeline => _controller.timeline;

  late final _controller = CueController(motion: .defaultTime, value: 1.0, vsync: this);

  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

  @override
  void initState() {
    super.initState();
   _controller.setProgress(1.0, forward: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedRevealedOffset = null;
    if (!widget.enabled) return;

    _subscribeToScrollPosition();
  }

  void _subscribeToScrollPosition() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) {
      throw FlutterError('Cue.onScrollVisible must be used inside a scrollable widget');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackViiblity();
    });
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_trackViiblity);
      _scrollPosition = position;
      _scrollPosition!.addListener(_trackViiblity);
    }
  }

  @override
  void didUpdateWidget(covariant _OnScrollVisibleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled) {
        _controller.setProgress(1.0, forward: true);
        _scrollPosition?.removeListener(_trackViiblity);
      } else {
        _subscribeToScrollPosition();
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_trackViiblity);
    super.dispose();
  }
  bool _isFirstFrame = true;

  AnimationStatus? _committedStatus;
  void _trackViiblity() async {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    if (!renderObject.attached || _scrollPosition == null) return;

    final revealedOffset = _cachedRevealedOffset ??= RenderAbstractViewport.of(
      renderObject,
    ).getOffsetToReveal(renderObject, 0.0).offset;

    // Widget is visible if its revealed offset is within current scroll range
    final scrollOffset = _scrollPosition!.pixels;
    final viewportDimension = _scrollPosition!.viewportDimension;

    final itemExtent = _scrollPosition!.axis == Axis.horizontal ? renderObject.size.width : renderObject.size.height;

    // Compute how many pixels of the widget overlap with the viewport
    final visibleStart = math.max(revealedOffset, scrollOffset);
    final visibleEnd = math.min(revealedOffset + itemExtent, scrollOffset + viewportDimension);
    final visibleExtent = visibleEnd - visibleStart;

    // Widget is considered visible when the visible fraction meets or exceeds the threshold.
    // A threshold of 0.0 means any overlap counts as visible.

    final visibleFraction = itemExtent > 0 ? (visibleExtent / itemExtent) : 0.0;

    final scrollDirection = _scrollPosition!.userScrollDirection;
    final isScrollingForward = scrollDirection == ScrollDirection.forward || (scrollDirection == ScrollDirection.idle);

    AnimationStatus status = _controller.status;

    if (visibleFraction == 0.0 || visibleFraction == 1.0) {
      _committedStatus = null;
      status = AnimationStatus.completed;
    } else if (_committedStatus == null) {
      // First frame mid-transition — commit direction now
      if (visibleFraction > _controller.value) {
        _committedStatus = isScrollingForward ? AnimationStatus.reverse : AnimationStatus.forward;
      } else if (visibleFraction < _controller.value) {
        _committedStatus = isScrollingForward ? AnimationStatus.forward : AnimationStatus.reverse;
      }
      status = _committedStatus ?? _controller.status;
    } else {
      status = _committedStatus!;
    }
    final target = visibleFraction.clamp(0.0, 1.0);

    if(target != 1 && target != 0.0 && _isFirstFrame){
      _isFirstFrame = false;
      _controller.setProgress(.5, forward: status.isForwardOrCompleted);
    }else{
    _controller.setProgress(target, forward: status.isForwardOrCompleted);
    }
  }
}
