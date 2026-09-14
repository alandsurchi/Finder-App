import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/lifecycle/app_lifecycle_provider.dart';

/// Polls [fetch] every [interval] while the app is in the foreground.
///
/// - Emits the first result as soon as it arrives.
/// - Pauses while the app is backgrounded and refreshes immediately on resume.
/// - Only emits when the result actually changed (by [equals], default
///   [listEquals]-style equality via `==`), so widgets do not rebuild for
///   identical data.
/// - Once something was loaded, transient failures keep the last value; an
///   error is only emitted when there is no data yet.
Stream<T> pollWhileVisible<T>(
  Ref ref, {
  required Duration interval,
  required Future<T> Function() fetch,
  bool Function(T a, T b)? equals,
}) {
  final controller = StreamController<T>();
  Timer? timer;
  bool disposed = false;
  bool inFlight = false;
  T? last;
  bool hasLast = false;
  final same = equals ?? (T a, T b) => a == b;

  Future<void> tick() async {
    if (disposed || inFlight) return;
    if (!ref.read(appIsResumedProvider)) return;
    inFlight = true;
    try {
      final value = await fetch();
      if (disposed) return;
      if (!hasLast || !same(last as T, value)) {
        last = value;
        hasLast = true;
        controller.add(value);
      }
    } catch (e, st) {
      if (!disposed && !hasLast) controller.addError(e, st);
    } finally {
      inFlight = false;
    }
  }

  void schedule() {
    timer?.cancel();
    timer = Timer.periodic(interval, (_) => tick());
  }

  tick();
  schedule();

  // Refresh right away when the app comes back to the foreground.
  final sub = ref.listen<bool>(appIsResumedProvider, (was, isNow) {
    if (isNow && was != true) {
      tick();
      schedule();
    }
  });

  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    sub.close();
    controller.close();
  });

  return controller.stream;
}

/// Equality for lists of value objects.
bool listsEqual<E>(List<E> a, List<E> b) => listEquals(a, b);
