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

class _DemoPageState extends State<DemoPage> {
  final _sheetController = DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue Demo'),
      ),
      body: Center(
        child: Cue.onHover(
          motion: .defaultTime,
          child: Actor(
            acts: [.scale(to: 1.5), .rotate(to: 15)],
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
            ),
          ),
        ),
      ),
      bottomSheet: DraggableScrollableSheet(
        controller: _sheetController,
        minChildSize: .2,
        builder: (context, scrollController) {
          return Container(
            color: Colors.grey,
            child: Cue.onProgress(
              listenable: _sheetController,
              min: 0.2,
              progress: ()=> _sheetController.isAttached ? _sheetController.size : 0.0,
              child: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Actor(
                    acts: [ .slideX(from: -.5)],
                    child: ListTile(
                      title: Text('Item $index'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
