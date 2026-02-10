import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'examples/three_dots_action.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cue Demo',
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DemoPage(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cue Demo')),
      body: Align(
        alignment: .center,
        child: Cue.onMount(
          debug: true,
          duration: Duration(seconds: 2),
          child: Actor(
            act: .group([
              Translate.keyframes([
                .key(Offset(0, -120), at: 0.25),
                .key(Offset(0, 0), at: 0.5),
                .key(Offset(0, -80), at: 0.65),
                .key(Offset(0, 0), at: 0.8),
                .key(Offset(0, -40), at: 0.9),
                .end(Offset(0, 0)),
              ]),
              Resize.keyframes([
                .start(.size(50, 50)),
                .key(.size(80, 80), at: 0.25),
                .key(.size(50, 50), at: 0.5),
                .key(.size(70, 70), at: 0.65),
                .key(.size(50, 50), at: 0.8),
                .key(.size(60, 60), at: 0.9),
                .end(.size(50, 50)),
              ]),
            ]),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
