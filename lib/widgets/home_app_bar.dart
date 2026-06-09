import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/routes.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/models/user_model.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value ?? UserModel.empty();

    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.surfaceHigh,
                ),
                child: Icon(Icons.person, color: t.onSurfaceVar),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back.',
                    style: TextStyle(
                      color: t.onSurfaceMuted,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        profile.fullName.isEmpty ? 'Guest' : profile.fullName,
                        style: TextStyle(
                          color: t.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: t.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.primary.withOpacity(0.1),
                border: Border.all(color: t.primary.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.notifications_none,
                color: t.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
