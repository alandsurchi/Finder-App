/// Pure state machine for the voice recorder, kept out of the widget so the
/// transitions can be unit-tested without the microphone plugin.
///
/// idle    --longPressStart--> holding
/// idle    --tap-------------> locked          (hands-free recording)
/// holding --slide up  >= 60-> locked
/// holding --slide in  >= 96-> cancel -> idle
/// holding --release---------> finish -> idle
/// locked  --tap send--------> finish -> idle
/// locked  --tap trash-------> cancel -> idle
/// any     --max duration----> finish -> idle
enum RecorderPhase { idle, holding, locked, finishing }

/// What the widget should do after a transition.
enum RecorderCommand { none, start, startLocked, lock, cancel, finish }

class VoiceRecorderMachine {
  static const double lockDistance = 60;
  static const double cancelDistance = 96;

  RecorderPhase phase = RecorderPhase.idle;

  /// Horizontal drag in "inward" pixels (positive = towards the text field).
  double dragX = 0;

  /// Vertical drag in pixels (negative = up).
  double dragY = 0;

  bool get isRecording => phase == RecorderPhase.holding || phase == RecorderPhase.locked;
  bool get locked => phase == RecorderPhase.locked;

  /// How close the finger is to locking (0..1), for the hint.
  double get lockProgress => phase == RecorderPhase.holding ? (-dragY / lockDistance).clamp(0.0, 1.0) : 0;

  RecorderCommand longPressStart() {
    if (phase != RecorderPhase.idle) return RecorderCommand.none;
    phase = RecorderPhase.holding;
    dragX = 0;
    dragY = 0;
    return RecorderCommand.start;
  }

  RecorderCommand tap() {
    switch (phase) {
      case RecorderPhase.idle:
        phase = RecorderPhase.locked;
        dragX = 0;
        dragY = 0;
        return RecorderCommand.startLocked;
      case RecorderPhase.locked:
        phase = RecorderPhase.finishing;
        return RecorderCommand.finish;
      case RecorderPhase.holding:
      case RecorderPhase.finishing:
        return RecorderCommand.none;
    }
  }

  /// Finger moved while holding. [dxInward] is positive towards the text
  /// field (already flipped for RTL), [dy] negative when moving up.
  RecorderCommand move(double dxInward, double dy) {
    if (phase != RecorderPhase.holding) return RecorderCommand.none;
    dragX = dxInward;
    dragY = dy;
    if (dxInward <= -cancelDistance) {
      phase = RecorderPhase.idle;
      return RecorderCommand.cancel;
    }
    if (dy <= -lockDistance) {
      phase = RecorderPhase.locked;
      dragX = 0;
      dragY = 0;
      return RecorderCommand.lock;
    }
    return RecorderCommand.none;
  }

  RecorderCommand release() {
    if (phase != RecorderPhase.holding) return RecorderCommand.none;
    phase = RecorderPhase.finishing;
    return RecorderCommand.finish;
  }

  RecorderCommand trash() {
    if (!isRecording) return RecorderCommand.none;
    phase = RecorderPhase.idle;
    return RecorderCommand.cancel;
  }

  RecorderCommand timeUp() {
    if (!isRecording) return RecorderCommand.none;
    phase = RecorderPhase.finishing;
    return RecorderCommand.finish;
  }

  /// The recorder stopped (sent or discarded) and the UI is idle again.
  void reset() {
    phase = RecorderPhase.idle;
    dragX = 0;
    dragY = 0;
  }

  /// Starting the microphone failed: back to idle.
  void startFailed() => reset();
}
