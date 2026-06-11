import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String? imageAsset;
  final VoidCallback? onTap;

  const SocialButton({
    Key? key,
    this.icon,
    this.color,
    this.imageAsset,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: imageAsset != null
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(imageAsset!),
                )
              : Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
        ),
      ),
    );
  }
}
