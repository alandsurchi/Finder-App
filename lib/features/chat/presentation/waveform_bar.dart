import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 40 amplitude buckets drawn as rounded bars; the played part is [fg].
/// Tap or drag to seek. Old notes without a waveform get a gentle pattern.
class WaveformBar extends StatelessWidget {
  final List<int>? waveform;
  final double progress; // 0..1
  final Color fg;
  final Color muted;
  final ValueChanged<double>? onSeek;
  final double height;

  const WaveformBar({
    super.key,
    required this.waveform,
    required this.progress,
    required this.fg,
    required this.muted,
    this.onSeek,
    this.height = 28,
  });

  static const int bars = 40;

  static List<double> normalise(List<int>? raw) {
    if (raw == null || raw.isEmpty) {
      // A quiet, plausible shape for notes recorded before waveforms existed.
      return List.generate(bars, (i) => 0.25 + 0.2 * math.sin(i * 0.9) * math.sin(i * 0.37));
    }
    final out = List<double>.filled(bars, 0);
    for (var i = 0; i < bars; i++) {
      final from = (i * raw.length / bars).floor();
      final to = math.max(from + 1, ((i + 1) * raw.length / bars).floor());
      var sum = 0.0;
      for (var j = from; j < to && j < raw.length; j++) {
        sum += raw[j].clamp(0, 100) / 100;
      }
      out[i] = (sum / (to - from)).clamp(0.08, 1.0);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, c) {
        void seekAt(double dx) {
          if (onSeek == null || c.maxWidth <= 0) return;
          var p = (dx / c.maxWidth).clamp(0.0, 1.0);
          if (rtl) p = 1 - p;
          onSeek!(p);
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seekAt(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
          child: CustomPaint(
            size: Size(c.maxWidth, height),
            painter: _WaveformPainter(
              values: normalise(waveform),
              progress: progress,
              fg: fg,
              muted: muted,
              rtl: rtl,
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final Color fg;
  final Color muted;
  final bool rtl;

  _WaveformPainter({
    required this.values,
    required this.progress,
    required this.fg,
    required this.muted,
    required this.rtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final slot = size.width / n;
    final barW = math.max(1.5, slot * 0.58);
    final played = Paint()..color = fg..strokeCap = StrokeCap.round..strokeWidth = barW;
    final rest = Paint()..color = muted..strokeCap = StrokeCap.round..strokeWidth = barW;
    final cutoff = progress * n;
    for (var i = 0; i < n; i++) {
      final logical = rtl ? n - 1 - i : i;
      final h = math.max(3.0, values[logical] * size.height);
      final x = slot * i + slot / 2;
      final y0 = (size.height - h) / 2;
      canvas.drawLine(Offset(x, y0), Offset(x, y0 + h), logical < cutoff ? played : rest);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.fg != fg || old.muted != muted || old.values != values || old.rtl != rtl;
}

/// Live bars while recording: the newest sample enters at the end.
class LiveWaveform extends StatelessWidget {
  final ValueListenable<List<double>> samples;
  final Color color;
  final double height;

  const LiveWaveform({super.key, required this.samples, required this.color, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<double>>(
      valueListenable: samples,
      builder: (context, list, _) {
        final tail = list.length > WaveformBar.bars ? list.sublist(list.length - WaveformBar.bars) : list;
        final padded = [...List.filled(WaveformBar.bars - tail.length, 0.08), ...tail];
        return CustomPaint(
          size: Size(double.infinity, height),
          painter: _WaveformPainter(
            values: padded,
            progress: 1,
            fg: color,
            muted: color,
            rtl: Directionality.of(context) == TextDirection.rtl,
          ),
        );
      },
    );
  }
}
