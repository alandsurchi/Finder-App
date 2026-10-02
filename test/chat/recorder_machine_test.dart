import 'package:flutter_test/flutter_test.dart';
import 'package:finder/features/chat/presentation/voice_recorder_machine.dart';

void main() {
  group('VoiceRecorderMachine', () {
    test('hold → release sends', () {
      final m = VoiceRecorderMachine();
      expect(m.longPressStart(), RecorderCommand.start);
      expect(m.phase, RecorderPhase.holding);
      expect(m.release(), RecorderCommand.finish);
      expect(m.phase, RecorderPhase.finishing);
      m.reset();
      expect(m.phase, RecorderPhase.idle);
    });

    test('hold → slide inwards cancels', () {
      final m = VoiceRecorderMachine()..longPressStart();
      expect(m.move(-40, 0), RecorderCommand.none);
      expect(m.move(-100, 0), RecorderCommand.cancel);
      expect(m.phase, RecorderPhase.idle);
    });

    test('hold → slide up locks, release no longer finishes', () {
      final m = VoiceRecorderMachine()..longPressStart();
      expect(m.move(0, -30), RecorderCommand.none);
      expect(m.lockProgress, closeTo(0.5, 0.01));
      expect(m.move(0, -70), RecorderCommand.lock);
      expect(m.locked, isTrue);
      expect(m.release(), RecorderCommand.none);
      expect(m.tap(), RecorderCommand.finish);
    });

    test('tap starts a locked recording; second tap sends', () {
      final m = VoiceRecorderMachine();
      expect(m.tap(), RecorderCommand.startLocked);
      expect(m.locked, isTrue);
      expect(m.tap(), RecorderCommand.finish);
    });

    test('trash cancels a locked recording', () {
      final m = VoiceRecorderMachine()..tap();
      expect(m.trash(), RecorderCommand.cancel);
      expect(m.phase, RecorderPhase.idle);
    });

    test('time limit finishes any recording', () {
      final m = VoiceRecorderMachine()..longPressStart();
      expect(m.timeUp(), RecorderCommand.finish);
      expect(VoiceRecorderMachine().timeUp(), RecorderCommand.none);
    });

    test('failed start returns to idle', () {
      final m = VoiceRecorderMachine()..longPressStart();
      m.startFailed();
      expect(m.phase, RecorderPhase.idle);
      expect(m.isRecording, isFalse);
    });
  });
}
