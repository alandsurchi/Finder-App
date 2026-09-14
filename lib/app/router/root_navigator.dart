import 'package:flutter/widgets.dart';

/// Root navigator, used to reset the stack when the session ends and to
/// open screens from push notifications.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
