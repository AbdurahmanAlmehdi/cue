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
      title: 'Wallet App',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
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
  bool isOpen = false;
  final drawerWidth = 320.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(
        title: const Text('Demo'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isOpen = !isOpen;
              });
            },
            icon: Icon(
              isOpen ? Icons.close : Icons.menu,
            ),
          )
        ],
      ),
      body: Cue.onToggle(
        toggled: isOpen,
        child: Column(children: [
          Actor(
            acts: [
               .slideX(to: 1, motion: .smooth()),
            ],
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            color: Colors.red,
          ),
        ],)
      ),
    );
  }
}
