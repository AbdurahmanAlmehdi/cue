part of 'cue.dart';

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    super.debugLabel,
    required this.controller,
    super.acts,
  }) : super._();

  final CueController controller;

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends CueState<_ControlledCue> {
  
  @override
  String get debugName => 'ControlledCue';

  @override
  CueController get controller => widget.controller;
}
