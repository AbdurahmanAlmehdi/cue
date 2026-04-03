part of 'cue.dart';

class CueScope extends InheritedWidget {
  const CueScope({
    super.key,
    required super.child,
    required this.controller,
    required this.reanimateFromCurrent,
  });

  final CueController controller;
  final bool reanimateFromCurrent;

  static CueScope of(BuildContext context) {
    final cue = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(cue != null, 'No Cue found in context, make sure to wrap your widget tree with a Cue widget.');
    return cue!;
  }

  static CueScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CueScope>();
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return controller != oldWidget.controller ||
        reanimateFromCurrent != oldWidget.reanimateFromCurrent;
  }
}

