import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/src/core/phase.dart';

void main() {
  group('Phase.normalize', () {
    group('Basic functionality', () {
      test('empty list returns empty list', () {
        final result = Phase.normalize<double>(0.0, []);
        expect(result, isEmpty);
      });

      test('single FullPhase returns unchanged', () {
        final phases = [
          const Phase(begin: 0.0, end: 100.0, weight: 1.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('single .to() phase uses base as begin', () {
        final phases = [
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('single .from() phase uses from value as begin and base as end', () {
        final phases = [
          const Phase.from(50.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 50.0, end: 0.0, weight: 1.0),
        ]);
      });

      test('single .hold() phase creates constant phase', () {
        final phases = [
          const Phase.hold(50.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const ConstantPhase(50.0),
        ]);
      });
    });

    group('Sequential .to() phases (chaining)', () {
      test('two .to() phases chain correctly', () {
        final phases = [
          const Phase.to(50.0),
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 50.0, weight: 1.0),
          const FullPhase(begin: 50.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('multiple .to() phases chain correctly', () {
        final phases = [
          const Phase.to(25.0),
          const Phase.to(50.0),
          const Phase.to(75.0),
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 25.0, weight: 1.0),
          const FullPhase(begin: 25.0, end: 50.0, weight: 1.0),
          const FullPhase(begin: 50.0, end: 75.0, weight: 1.0),
          const FullPhase(begin: 75.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('Offset sequence like user example', () {
        final phases = [
          const Phase.to(Offset(50, 0)),
          const Phase.to(Offset(50, 50)),
          const Phase.to(Offset(0, 50)),
          const Phase.to(Offset(0, 0)),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result, [
          const FullPhase(begin: Offset(0, 0), end: Offset(50, 0), weight: 1.0),
          const FullPhase(begin: Offset(50, 0), end: Offset(50, 50), weight: 1.0),
          const FullPhase(begin: Offset(50, 50), end: Offset(0, 50), weight: 1.0),
          const FullPhase(begin: Offset(0, 50), end: Offset(0, 0), weight: 1.0),
        ]);
      });
    });

    group('Weight handling', () {
      test('.to() phase with custom weight', () {
        final phases = [
          const Phase.to(100.0, weight: 2.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 100.0, weight: 2.0),
        ]);
      });

      test('multiple .to() phases with different weights', () {
        final phases = [
          const Phase.to(25.0, weight: 1.0),
          const Phase.to(50.0, weight: 2.0),
          const Phase.to(100.0, weight: 3.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 25.0, weight: 1.0),
          const FullPhase(begin: 25.0, end: 50.0, weight: 2.0),
          const FullPhase(begin: 50.0, end: 100.0, weight: 3.0),
        ]);
      });

      test('.hold() phase with custom weight', () {
        final phases = [
          const Phase.hold(50.0, weight: 5.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const ConstantPhase(50.0, weight: 5.0),
        ]);
      });

      test('.from() phase with custom weight', () {
        final phases = [
          const Phase.from(75.0, weight: 3.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 75.0, end: 0.0, weight: 3.0),
        ]);
      });

      test('FullPhase with custom weight', () {
        final phases = [
          const Phase(begin: 0.0, end: 100.0, weight: 4.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 100.0, weight: 4.0),
        ]);
      });

      test('Offset sequence with mixed weights', () {
        final phases = [
          const Phase.to(Offset(50, 0), weight: 1.0),
          const Phase.to(Offset(50, 50), weight: 2.0),
          const Phase.to(Offset(0, 50), weight: 1.5),
          const Phase.to(Offset(0, 0), weight: 0.5),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result, [
          const FullPhase(begin: Offset(0, 0), end: Offset(50, 0), weight: 1.0),
          const FullPhase(begin: Offset(50, 0), end: Offset(50, 50), weight: 2.0),
          const FullPhase(begin: Offset(50, 50), end: Offset(0, 50), weight: 1.5),
          const FullPhase(begin: Offset(0, 50), end: Offset(0, 0), weight: 0.5),
        ]);
      });
    });

    group('Mixed phase types', () {
      test('FullPhase followed by .to()', () {
        final phases = [
          const Phase(begin: 0.0, end: 50.0, weight: 1.0),
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 50.0, weight: 1.0),
          const FullPhase(begin: 50.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('.to() followed by FullPhase', () {
        final phases = [
          const Phase.to(50.0),
          const Phase(begin: 100.0, end: 150.0, weight: 1.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 50.0, weight: 1.0),
          const FullPhase(begin: 100.0, end: 150.0, weight: 1.0),
        ]);
      });

      test('.to() with .hold()', () {
        final phases = [
          const Phase.to(50.0),
          const Phase.hold(50.0, weight: 2.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 50.0, weight: 1.0),
          const ConstantPhase(50.0, weight: 2.0),
        ]);
      });

      test('sequence with .hold() in the middle', () {
        final phases = [
          const Phase.to(50.0),
          const Phase.hold(50.0, weight: 3.0),
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result.length, 3);
        expect(result[0], const FullPhase(begin: 0.0, end: 50.0, weight: 1.0));
        expect(result[1], isA<ConstantPhase<double>>());
        expect(result[1].begin, 50.0);
        expect(result[1].end, 50.0);
        expect(result[1].weight, 3.0);
        expect(result[2], const FullPhase(begin: 50.0, end: 100.0, weight: 1.0));
      });

      test('.from() followed by .to()', () {
        final phases = [
          const Phase.from(25.0),
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 25.0, end: 100.0, weight: 1.0),
          const FullPhase(begin: 100.0, end: 100.0, weight: 1.0),
        ]);
      });
    });

    group('User-like shorthand patterns', () {
      test('simple square path with .to()', () {
        final phases = [
          const Phase.to(Offset(50, 0)),
          const Phase.to(Offset(50, 50)),
          const Phase.to(Offset(0, 50)),
          const Phase.to(Offset(0, 0)),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result.length, 4);
        expect(result[0].begin, Offset.zero);
        expect(result[0].end, const Offset(50, 0));
        expect(result[1].begin, const Offset(50, 0));
        expect(result[1].end, const Offset(50, 50));
        expect(result[2].begin, const Offset(50, 50));
        expect(result[2].end, const Offset(0, 50));
        expect(result[3].begin, const Offset(0, 50));
        expect(result[3].end, Offset.zero);
      });

      test('square path with .hold() at end', () {
        final phases = [
          const Phase.to(Offset(50, 0)),
          const Phase.to(Offset(50, 50)),
          const Phase.to(Offset(0, 50)),
          const Phase.to(Offset(0, 0)),
          const Phase.hold(Offset.zero, weight: 2.0),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result.length, 5);
        expect(result[4], isA<ConstantPhase<Offset>>());
        expect(result[4].begin, Offset.zero);
        expect(result[4].end, Offset.zero);
        expect(result[4].weight, 2.0);
      });

      test('complex sequence with varied weights', () {
        final phases = [
          const Phase.to(Offset(100, 0), weight: 2.0),
          const Phase.hold(Offset(100, 0), weight: 1.0),
          const Phase.to(Offset(100, 100), weight: 2.0),
          const Phase.hold(Offset(100, 100), weight: 1.0),
          const Phase.to(Offset(0, 100), weight: 2.0),
          const Phase.hold(Offset(0, 100), weight: 1.0),
          const Phase.to(Offset.zero, weight: 2.0),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result.length, 7);
        expect(result[0].weight, 2.0);
        expect(result[1].weight, 1.0);
        expect(result[2].weight, 2.0);
        expect(result[3].weight, 1.0);
      });
    });

    group('Different types', () {
      test('works with int', () {
        final phases = [
          const Phase.to(10),
          const Phase.to(20),
          const Phase.to(30),
        ];
        final result = Phase.normalize(0, phases);
        expect(result, [
          const FullPhase(begin: 0, end: 10, weight: 1.0),
          const FullPhase(begin: 10, end: 20, weight: 1.0),
          const FullPhase(begin: 20, end: 30, weight: 1.0),
        ]);
      });

      test('works with Color', () {
        final phases = [
          const Phase.to(Colors.red),
          const Phase.to(Colors.green),
          const Phase.to(Colors.blue),
        ];
        final result = Phase.normalize(Colors.white, phases);
        expect(result.length, 3);
        expect(result[0].begin, Colors.white);
        expect(result[0].end, Colors.red);
        expect(result[1].begin, Colors.red);
        expect(result[1].end, Colors.green);
        expect(result[2].begin, Colors.green);
        expect(result[2].end, Colors.blue);
      });

      test('works with Size', () {
        final phases = [
          const Phase.to(Size(100, 100)),
          const Phase.to(Size(200, 200)),
        ];
        final result = Phase.normalize(const Size(0, 0), phases);
        expect(result, [
          const FullPhase(begin: Size(0, 0), end: Size(100, 100), weight: 1.0),
          const FullPhase(begin: Size(100, 100), end: Size(200, 200), weight: 1.0),
        ]);
      });
    });

    group('Edge cases', () {
      test('base value is used correctly', () {
        final phases = [
          const Phase.to(100.0),
        ];
        final result = Phase.normalize(50.0, phases);
        expect(result, [
          const FullPhase(begin: 50.0, end: 100.0, weight: 1.0),
        ]);
      });

      test('non-zero base with multiple phases', () {
        final phases = [
          const Phase.to(200.0),
          const Phase.to(300.0),
        ];
        final result = Phase.normalize(100.0, phases);
        expect(result, [
          const FullPhase(begin: 100.0, end: 200.0, weight: 1.0),
          const FullPhase(begin: 200.0, end: 300.0, weight: 1.0),
        ]);
      });

      test('phases with same begin and end values', () {
        final phases = [
          const Phase.to(50.0),
          const Phase.hold(50.0),
          const Phase.to(50.0),
        ];
        final result = Phase.normalize(50.0, phases);
        expect(result.length, 3);
        expect(result[0], const FullPhase(begin: 50.0, end: 50.0, weight: 1.0));
        expect(result[1], isA<ConstantPhase<double>>());
        expect(result[1].begin, 50.0);
        expect(result[1].end, 50.0);
        expect(result[1].weight, 1.0);
        expect(result[2], const FullPhase(begin: 50.0, end: 50.0, weight: 1.0));
      });

      test('backwards movement (decreasing values)', () {
        final phases = [
          const Phase.to(100.0),
          const Phase.to(50.0),
          const Phase.to(0.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: 100.0, weight: 1.0),
          const FullPhase(begin: 100.0, end: 50.0, weight: 1.0),
          const FullPhase(begin: 50.0, end: 0.0, weight: 1.0),
        ]);
      });

      test('negative values', () {
        final phases = [
          const Phase.to(-50.0),
          const Phase.to(-100.0),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result, [
          const FullPhase(begin: 0.0, end: -50.0, weight: 1.0),
          const FullPhase(begin: -50.0, end: -100.0, weight: 1.0),
        ]);
      });
    });

    group('Real-world animation scenarios', () {
      test('bounce animation pattern', () {
        final phases = [
          const Phase.to(100.0, weight: 2.0),
          const Phase.to(80.0, weight: 0.5),
          const Phase.to(100.0, weight: 0.5),
          const Phase.to(90.0, weight: 0.3),
          const Phase.to(100.0, weight: 0.3),
        ];
        final result = Phase.normalize(0.0, phases);
        expect(result.length, 5);
        expect(result[0].begin, 0.0);
        expect(result[0].end, 100.0);
        expect(result[1].begin, 100.0);
        expect(result[1].end, 80.0);
      });

      test('pause and resume pattern', () {
        final phases = [
          const Phase.to(Offset(100, 0), weight: 2.0),
          const Phase.hold(Offset(100, 0), weight: 3.0),
          const Phase.to(Offset(200, 0), weight: 2.0),
          const Phase.hold(Offset(200, 0), weight: 3.0),
          const Phase.to(Offset(300, 0), weight: 2.0),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result.length, 5);
        expect(result[1].begin, const Offset(100, 0));
        expect(result[1].end, const Offset(100, 0));
        expect(result[3].begin, const Offset(200, 0));
        expect(result[3].end, const Offset(200, 0));
      });

      test('diagonal movement with holds', () {
        final phases = [
          const Phase.to(Offset(50, 50), weight: 1.0),
          const Phase.hold(Offset(50, 50), weight: 0.5),
          const Phase.to(Offset(100, 100), weight: 1.0),
          const Phase.hold(Offset(100, 100), weight: 0.5),
          const Phase.to(Offset(0, 0), weight: 2.0),
        ];
        final result = Phase.normalize(Offset.zero, phases);
        expect(result.length, 5);
        expect(result[0].weight, 1.0);
        expect(result[1].weight, 0.5);
        expect(result[4].weight, 2.0);
      });
    });
  });
}
