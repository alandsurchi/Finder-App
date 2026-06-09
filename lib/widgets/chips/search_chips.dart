import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

class RecentChip extends StatelessWidget {
  final String label;
  
  const RecentChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 14, color: t.onSurfaceMuted),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: t.onSurfaceVar, fontSize: 13)),
        ],
      ),
    );
  }
}

class PopularChip extends StatelessWidget {
  final String label;
  
  const PopularChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: t.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
            color: t.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}
