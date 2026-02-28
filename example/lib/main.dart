import 'dart:math';

import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
import 'package:example/examples/indicator_to_button.dart';
import 'package:example/examples/three_dots_action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Curves.elasticIn;
    return MaterialApp(
      title: 'Cue Demo',
      // showPerformanceOverlay: true,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _OnChangeDemo(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

class _OnChangeDemo extends StatefulWidget {
  const _OnChangeDemo({super.key});

  @override
  State<_OnChangeDemo> createState() => __OnChangeDemoState();
}

class __OnChangeDemoState extends State<_OnChangeDemo> {
  int _notificationsCount = 0;
  bool _checked = false;
  final _cuePageController = CuePageController(viewportFraction: .8);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 60),
        child: Center(
          child: Cue.onToggle(
            toggled: _checked,
            motion: .simulation(Spring.bouncy(damping: 16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                setState(() {
                  _checked = !_checked;
                });
              },
              child: SizedBox.square(
                dimension: 44,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    clipBehavior: Clip.antiAlias,
                    children: [
                      SlideActor.y(
                        from: 0,
                        to: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SlideActor.y(
                        from: -1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('Show Sheet'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(),
                            body: Cue.onTransition(
                              child: Center(
                                child: SlideActor.y(
                                  from: 10.0,
                                  child: Text('Hello from the new page!'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
