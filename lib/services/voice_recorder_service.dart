import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final voiceRecorderProvider = Provider<VoiceRecorderService>((ref) {
  final s = VoiceRecorderService();
  ref.onDispose(s.dispose);
  return s;
});

/// A finished recording: the file on disk and how long it is.
class VoiceRecording {
  final String path;
  final int durationMs;
  const VoiceRecording(this.path, this.durationMs);
}

/// Records voice notes as AAC in an .m4a container (plays on iOS, Android
/// and in browsers). One recording at a time.
class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _startedAt;
  String? _path;

  static const int maxDurationMs = 10 * 60 * 1000;

  bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isRecording => _startedAt != null;

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Starts recording. Returns false when the microphone is not available.
  Future<bool> start() async {
    if (!supported || isRecording) return false;
    if (!await _recorder.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice-${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          noiseSuppress: true,
        ),
        path: path,
      );
      _path = path;
      _startedAt = DateTime.now();
      return true;
    } catch (e) {
      debugPrint('Voice recording failed to start: $e');
      _path = null;
      _startedAt = null;
      return false;
    }
  }

  /// Milliseconds since [start].
  int get elapsedMs =>
      _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds;

  /// Current input level in dBFS (-160..0), for the pulsing dot.
  Future<double> amplitude() async {
    try {
      final a = await _recorder.getAmplitude();
      return a.current;
    } catch (_) {
      return -160;
    }
  }

  /// Stops and returns the recording, or null if nothing usable was captured.
  Future<VoiceRecording?> stop() async {
    if (!isRecording) return null;
    final duration = elapsedMs;
    _startedAt = null;
    try {
      final out = await _recorder.stop();
      final path = out ?? _path;
      _path = null;
      if (path == null) return null;
      final file = File(path);
      if (!await file.exists() || await file.length() < 1024) {
        await _delete(path);
        return null;
      }
      return VoiceRecording(path, duration);
    } catch (e) {
      debugPrint('Voice recording failed to stop: $e');
      return null;
    }
  }

  /// Stops and throws the recording away.
  Future<void> cancel() async {
    if (!isRecording) return;
    _startedAt = null;
    try {
      final out = await _recorder.stop();
      await _delete(out ?? _path);
    } catch (_) {}
    _path = null;
  }

  Future<void> _delete(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  void dispose() {
    _recorder.dispose();
  }
}
