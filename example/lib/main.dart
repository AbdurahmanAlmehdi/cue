import 'package:cue/cue.dart';
import 'package:example/examples/expanding_cards.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

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
      home: DemoPage(),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [ExpandingCards()],
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
      appBar: AppBar(
        // bottom: TabBar(
        //   controller: _cueController,
        //   tabs: [
        //     for (int index = 0; index < 5; index++)
        //       Tab(
        //         child: Text('Tab ${index + 1}'),
        //       ),
        //   ],
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SizedBox(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              for (int index = 0; index < 20; index++)
                Cue.onScrollVisible(
                  key: Key('page_${index + 1}'),
                  enabled: true,
                  child: ScaleActor(
                    from: .5,
                    to: 1,
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.primaries[index % Colors.primaries.length].shade200,
                      child: Center(
                        child: Text(
                          'Page ${index + 1}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
