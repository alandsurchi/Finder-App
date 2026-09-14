import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which tab of the Home shell is showing: 0 Home, 1 Search, 2 Post,
/// 3 Messages, 4 Profile. Lives outside the shell so any screen can switch
/// tabs (for example "Back" after posting should land on Home).
final homeTabProvider = StateProvider<int>((ref) => 0);

/// Lost/Found pre-selection for the Post tab, set by the Home hero tiles.
/// Null means "keep whatever the form already has".
final createPrefillProvider = StateProvider<bool?>((ref) => null);

abstract final class HomeTabs {
  static const int home = 0;
  static const int search = 1;
  static const int post = 2;
  static const int messages = 3;
  static const int profile = 4;
}
