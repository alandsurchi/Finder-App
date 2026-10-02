import 'dart:async';
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

/// A finished recording: the file on disk, its length and the loudness
/// buckets (0-100) the bubble draws as a waveform.
class VoiceRecording {
  final String path;
  final int durationMs;
  final List<int> waveform;
  const VoiceRecording(this.path, this.durationMs, {this.waveform = const []});
}

/// Records voice notes as AAC in an .m4a container (plays on iOS, Android
/// and in browsers). One recording at a time. While recording, [samples]
/// receives a normalised level ten times a second for the live waveform.
class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _startedAt;
  String? _path;
  Timer? _sampler;
  final List<double> _levels = [];

  /// Live levels (0..1), newest last.
  final ValueNotifier<List<double>> samples = ValueNotifier(const []);

  static const int maxDurationMs = 10 * 60 * 1000;
  static const int waveformBuckets = 40;

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
      _levels.clear();
      samples.value = const [];
      _sampler = Timer.periodic(const Duration(milliseconds: 100), (_) => _sample());
      return true;
    } catch (e) {
      debugPrint('Voice recording failed to start: $e');
      _path = null;
      _startedAt = null;
      return false;
    }
  }

  Future<void> _sample() async {
    if (!isRecording) return;
    final db = await amplitude();
    // dBFS -50..0 → 0..1; speech sits around -30..-10.
    final level = ((db + 50) / 50).clamp(0.0, 1.0);
    _levels.add(level);
    samples.value = List.unmodifiable(_levels);
  }

  /// Milliseconds since [start].
  int get elapsedMs =>
      _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds;

  /// Current input level in dBFS (-160..0).
  Future<double> amplitude() async {
    try {
      final a = await _recorder.getAmplitude();
      return a.current;
    } catch (_) {
      return -160;
    }
  }

  /// Squeezes the captured levels into [waveformBuckets] integers 0-100.
  List<int> _bucketed() {
    if (_levels.isEmpty) return const [];
    final n = waveformBuckets;
    final out = List<int>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final from = (i * _levels.length / n).floor();
      final to = ((i + 1) * _levels.length / n).floor().clamp(from + 1, _levels.length);
      var peak = 0.0;
      for (var j = from; j < to; j++) {
        if (_levels[j] > peak) peak = _levels[j];
      }
      out[i] = (peak * 100).round();
    }
    return out;
  }

  void _stopSampling() {
    _sampler?.cancel();
    _sampler = null;
  }

  /// Stops and returns the recording, or null if nothing usable was captured.
  Future<VoiceRecording?> stop() async {
    if (!isRecording) return null;
    final duration = elapsedMs;
    final waveform = _bucketed();
    _startedAt = null;
    _stopSampling();
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
      return VoiceRecording(path, duration, waveform: waveform);
    } catch (e) {
      debugPrint('Voice recording failed to stop: $e');
      return null;
    }
  }

  /// Stops and throws the recording away.
  Future<void> cancel() async {
    if (!isRecording) return;
    _startedAt = null;
    _stopSampling();
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
    _stopSampling();
    samples.dispose();
    _recorder.dispose();
  }
}
