import 'package:cue/cue.dart';
import 'package:flutter/material.dart';


class CueDialogRoute<T extends Object?> extends RawDialogRoute<T> with CueModalRouteMixin<T> {
  CueDialogRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    required this.motion,
    this.reverseMotion,
    this.onAnimationStatusChanged,
    this.hideOnPushNext = true,
  }) : super(transitionBuilder: (_, _, _, child) => child);

  @override
  final CueMotion motion;

  @override
  final CueMotion? reverseMotion;

  @override
  final AnimationStatusListener? onAnimationStatusChanged;

  @override
  final bool hideOnPushNext;
}

@optionalTypeArgs
Future<T?> showCueDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'CueDialog',
  Color barrierColor = const Color(0x80000000),
  CueMotion motion = .defaultTime,
  CueMotion? reverseMotion,
  bool useRootNavigator = true,
}) {
  assert(debugCheckHasMaterialLocalizations(context));
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    CueDialogRoute<T>(
      pageBuilder: (context, _, _) => themes.wrap(builder(context)),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      motion: motion,
      reverseMotion: reverseMotion,
    ),
  );
}

 