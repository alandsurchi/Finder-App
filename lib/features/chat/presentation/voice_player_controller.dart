import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Playback state of the one voice note that is playing (or paused).
class VoicePlayback {
  final String source;
  final bool playing;
  final bool loading;
  final Duration position;
  final Duration? duration;
  final double speed;

  const VoicePlayback({
    required this.source,
    this.playing = false,
    this.loading = false,
    this.position = Duration.zero,
    this.duration,
    this.speed = 1,
  });

  VoicePlayback copyWith({
    bool? playing,
    bool? loading,
    Duration? position,
    Duration? duration,
    double? speed,
  }) =>
      VoicePlayback(
        source: source,
        playing: playing ?? this.playing,
        loading: loading ?? this.loading,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        speed: speed ?? this.speed,
      );
}

/// One shared player for every voice bubble: starting a note stops the
/// previous one, like WhatsApp. State is null when nothing is loaded.
class VoicePlayerController extends StateNotifier<VoicePlayback?> {
  VoicePlayerController() : super(null) {
    _posSub = _player.positionStream.listen((p) {
      final s = state;
      if (s != null) state = s.copyWith(position: p);
    });
    _stateSub = _player.playerStateStream.listen((ps) {
      final s = state;
      if (s == null) return;
      if (ps.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
        state = s.copyWith(playing: false, position: Duration.zero, loading: false);
        return;
      }
      state = s.copyWith(
        playing: ps.playing,
        loading: ps.processingState == ProcessingState.loading ||
            ps.processingState == ProcessingState.buffering,
      );
    });
    _durSub = _player.durationStream.listen((d) {
      final s = state;
      if (s != null && d != null) state = s.copyWith(duration: d);
    });
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration?>? _durSub;

  static const speeds = [1.0, 1.5, 2.0];

  /// Chosen speed survives from note to note for the session.
  double _speed = 1;
  double get speed => _speed;

  bool isCurrent(String source) => state?.source == source;

  /// Play/pause [source] (a URL or a local file path).
  Future<void> toggle(String source) async {
    if (source.isEmpty) return;
    try {
      if (isCurrent(source)) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }
      state = VoicePlayback(source: source, loading: true, speed: _speed);
      if (source.startsWith('http')) {
        await _player.setUrl(source);
      } else {
        await _player.setFilePath(source);
      }
      await _player.setSpeed(_speed);
      await _player.play();
    } catch (e) {
      debugPrint('Voice playback failed: $e');
      state = null;
    }
  }

  Future<void> seek(String source, Duration to) async {
    if (!isCurrent(source)) return;
    await _player.seek(to);
  }

  /// 1× → 1.5× → 2× → 1×.
  Future<void> cycleSpeed() async {
    final i = speeds.indexOf(_speed);
    _speed = speeds[(i + 1) % speeds.length];
    try {
      await _player.setSpeed(_speed);
    } catch (_) {}
    final s = state;
    if (s != null) state = s.copyWith(speed: _speed);
  }

  Future<void> stop() async {
    await _player.stop();
    state = null;
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final voicePlayerProvider =
    StateNotifierProvider.autoDispose<VoicePlayerController, VoicePlayback?>(
  (ref) => VoicePlayerController(),
);
