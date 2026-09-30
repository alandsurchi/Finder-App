import 'package:flutter/material.dart';
import 'package:finder/screens/chat_screen.dart';
import 'package:finder/screens/create_post_screen.dart';
import 'package:finder/screens/edit_profile_screen.dart';
import 'package:finder/screens/get_verified_screen.dart';
import 'package:finder/screens/help_support_screen.dart';
import 'package:finder/screens/home_screen.dart';
import 'package:finder/screens/item_details_screen.dart';
import 'package:finder/screens/login_screen.dart';
import 'package:finder/screens/messages_screen.dart';
import 'package:finder/screens/my_posts_screen.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/screens/notification_settings_screen.dart';
import 'package:finder/screens/user_profile_screen.dart';
import 'package:finder/screens/notifications_screen.dart';
import 'package:finder/screens/onboarding_screen.dart';
import 'package:finder/screens/privacy_settings_screen.dart';
import 'package:finder/screens/profile_screen.dart';
import 'package:finder/screens/saved_items_screen.dart';
import 'package:finder/screens/search_screen.dart';
import 'package:finder/screens/signup_screen.dart';
import 'package:finder/screens/forgot_password_screen.dart';
import 'package:finder/screens/email_verification_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case RouteNames.chat:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChatScreen(),
        );
      case RouteNames.itemDetails:
        // With a hero on screen the page fades in behind the flying image;
        // without one (links, notifications) the platform transition is used.
        final details = ItemDetailsArgs.from(settings.arguments);
        if (details?.heroTag == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ItemDetailsScreen(),
          );
        }
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) => const ItemDetailsScreen(),
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        );
      case RouteNames.userProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UserProfileScreen(),
        );
      case RouteNames.createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteNames.getVerified:
        return MaterialPageRoute(builder: (_) => const GetVerifiedScreen());
      case RouteNames.helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case RouteNames.messages:
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      case RouteNames.myPosts:
        return MaterialPageRoute(builder: (_) => const MyPostsScreen());
      case RouteNames.notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
        );
      case RouteNames.privacySettings:
        return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.savedItems:
        return MaterialPageRoute(builder: (_) => const SavedItemsScreen());
      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.emailVerification:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
      default:
        return null;
    }
  }
}
