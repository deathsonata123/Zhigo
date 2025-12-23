import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// User Avatar Widget
/// Shows first letter of name or profile image
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: imageUrl == null
              ? LinearGradient(
                  colors: [AppColors.accent, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: imageUrl == null
            ? Center(
                child: Text(
                  _getInitial(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _getInitial() {
    if (name == null || name!.isEmpty) return '?';
    return name![0].toUpperCase();
  }
}
