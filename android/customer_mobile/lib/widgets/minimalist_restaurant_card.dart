import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Minimalist Restaurant Card - Progressive Disclosure Design
/// Edge-to-edge hero image with overlaid restaurant name and rating
class MinimalistRestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;
  final double aspectRatio; // For bento box varied sizing

  const MinimalistRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.aspectRatio = 0.75, // Default portrait
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: aspectRatio, // Dynamic aspect ratio for bento variety
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hero Image - Edge to Edge
                if (restaurant['imageUrl'] != null)
                  CachedNetworkImage(
                    imageUrl: restaurant['imageUrl'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.baseOffWhite,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.baseOffWhite,
                      child: const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  Container(
                    color: AppColors.baseOffWhite,
                    child: const Icon(
                      Icons.restaurant,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),

                // Gradient Overlay (subtle, only at bottom)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Restaurant Info - Overlaid at Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Restaurant Name
                        Text(
                          restaurant['name'] ?? 'Restaurant',
                          style: AppTextStyles.bodyEmphasized.copyWith(
                            color: AppColors.baseWhite,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Rating - Clean, Semi-Translucent Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.baseWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.baseWhite.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFFC107), // Gold star
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (restaurant['rating'] ?? 4.5).toString(),
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.baseWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
