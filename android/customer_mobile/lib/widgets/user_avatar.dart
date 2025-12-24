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
          gradient: (imageUrl == null || imageUrl!.isEmpty)
              ? LinearGradient(
                  colors: _getAvatarColors(name),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          image: (imageUrl != null && imageUrl!.isNotEmpty)
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
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Center(
                child: Text(
                  _getInitial(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _getInitial() {
    if (name == null || name!.trim().isEmpty) return '?';
    
    // Split by space and get first letters of first two words if possible
    final parts = name!.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  List<Color> _getAvatarColors(String? name) {
    if (name == null || name.isEmpty) {
      return [AppColors.accent, AppColors.secondary];
    }

    // Google-style dynamic colors based on name hash
    final colors = [
      [const Color(0xFF4285F4), const Color(0xFF1967D2)], // Blue
      [const Color(0xFFEA4335), const Color(0xFFB31412)], // Red
      [const Color(0xFFFBBC05), const Color(0xFFF29900)], // Yellow
      [const Color(0xFF34A853), const Color(0xFF137333)], // Green
      [AppColors.accent, AppColors.secondary], // Brand
    ];

    final index = name.length % colors.length;
    return colors[index];
  }
}
