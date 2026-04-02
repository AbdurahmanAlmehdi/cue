import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cue Demo',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: .light,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const DemoPage(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
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

class _DemoPageState extends State<DemoPage> with TickerProviderStateMixin {

  late final _controller = CueController(vsync: this, motion: .smooth());
  late final opacity = _controller.tweenTrack(from: 0.0, to: 1.1);

  late final translate = _controller.keyframedTrack(
    frames: Keyframes([
      Keyframe(Offset.zero, motion: .none),
      Keyframe(const Offset(200, 0), motion: .linear(300.ms)),
      Keyframe(const Offset(200, 200), motion: .linear(300.ms)),
      Keyframe(const Offset(0, 200), motion: .linear(300.ms)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cue Demo')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _controller.forward(from: 0.0);
            },
            child: const Text('Animate'),
          ),
          Expanded(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: translate,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  builder: (context, child) {
                    return Positioned(
                      left: translate.value.dx,
                      top: translate.value.dy,
                      height: 50,
                      width: 50,
                      child: child!,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
