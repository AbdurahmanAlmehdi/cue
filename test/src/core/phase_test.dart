import 'package:flutter_test/flutter_test.dart';
import 'package:cue/src/core/phase.dart';
import 'package:cue/src/motion/cue_motion.dart';

void main() {
  group('Phase.resolveFractionalFrames', () {
    test('empty list returns empty', () {
      final phases = Phase.resolveFractionalFrames([], transform: (v) => v);
      expect(phases, isEmpty);
    });

    test('single fractional keyframe returns constant phase', () {
      final frames = [FractionalKeyframe.key(100.0, at: 0.0)];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [const Phase(begin: 100.0, end: 100.0)]);
    });

    test('two fractional keyframes produce one phase', () {
      final frames = [
        FractionalKeyframe.key(0.0, at: 0.0),
        FractionalKeyframe.key(100.0, at: 1.0),
      ];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [const Phase(begin: 0.0, end: 100.0)]);
    });

    test('duplicates at same time keep last value', () {
      final frames = [
        FractionalKeyframe.key(10.0, at: 0.0),
        FractionalKeyframe.key(20.0, at: 0.0),
        FractionalKeyframe.key(30.0, at: 1.0),
      ];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      // First time 0.0 should use last value 20.0 -> phase: 20 -> 30
      expect(phases, [const Phase(begin: 20.0, end: 30.0)]);
    });

  });

  group('Phase.resolveMotionFrames', () {
    test('empty list returns empty', () {
      final phases = Phase.resolveMotionFrames<double, double>([], transform: (v) => v);
      expect(phases, isEmpty);
    });

    test('motion keyframes produce phases preserving order', () {
      final frames = [
        Keyframe.key(0.0, motion: CueMotion.none),
        Keyframe.key(50.0, motion: CueMotion.linear(const Duration(milliseconds: 100))),
        Keyframe.key(100.0, motion: CueMotion.none),
      ];
      final phases = Phase.resolveMotionFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [
        const Phase(begin: 0.0, end: 50.0),
        const Phase(begin: 50.0, end: 100.0),
      ]);
    });

    test('from value is respected when provided', () {
      final frames = [Keyframe.key(10.0, motion: CueMotion.none)];
      final phases = Phase.resolveMotionFrames<double, double>(frames, from: 0.0, transform: (v) => v);
      expect(phases, [const Phase(begin: 0.0, end: 10.0)]);
    });
  });

  group('Phase equality', () {
    test('identical begin/end are equal', () {
      const a = Phase(begin: 0.0, end: 100.0);
      const b = Phase(begin: 0.0, end: 100.0);
      expect(a, equals(b));
    });

    test('different begin or end are not equal', () {
      const a = Phase(begin: 0.0, end: 100.0);
      const b = Phase(begin: 10.0, end: 100.0);
      const c = Phase(begin: 0.0, end: 50.0);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
    });
  });
}
