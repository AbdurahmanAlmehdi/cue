import 'dart:math';

import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
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
      // backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 60),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: .end,
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _cuePageController,
                  itemCount: 5,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Cue.indexed(
                      index: index,
                      controller: _cuePageController,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        elevation: .2,
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 88,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 5; i++)
                      Builder(
                        builder: (context) {
                          final isLast = i == 4;
                          return Cue.indexed(
                            index: i,
                            controller: _cuePageController,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: SizeActor(
                                  from: .square(10),
                                  to: isLast ? .fromHeight(44) : NSize(38, 10),
                                  allowOverflow: isLast,
                                  child: isLast
                                      ? ScaleActor(
                                          from: 0,
                                          child: SlideActor(
                                            from: Offset(-1, 0),
                                            child: Padding(
                                              padding: const .symmetric(horizontal: 16),
                                              child: Row(
                                                mainAxisAlignment: .center,
                                                children: [
                                                  Text(
                                                    'Let’s Go',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
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
