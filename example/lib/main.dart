import 'dart:developer';

import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
import 'package:example/examples/slack_style_fab.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cue Demo')),
      body: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Builder(
                    builder: (context) {
                      return Cue.onMount(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < 5; i++)
                              Actor(
                                motion: .smooth(),
                                acts: [
                                  .slideX(
                                    from: -1,
                                    delay: 20.ms * i,
                                  ),
                                ],
                                child: ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) => const DeleteConfirmationDialog(),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Text("Navigate"),
          ),
        ],
      ),
    );
  }
}
