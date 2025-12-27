import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Minimalist Restaurant Card with Hover Effects
/// Edge-to-edge hero image with overlaid restaurant name and rating
class MinimalistRestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;
  final double aspectRatio;

  const MinimalistRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.aspectRatio = 0.75,
  });

  @override
  State<MinimalistRestaurantCard> createState() => _MinimalistRestaurantCardState();
}

class _MinimalistRestaurantCardState extends State<MinimalistRestaurantCard> {
  bool _isHovered = false;

  // Get the image URL - check both possible field names
  String? get _imageUrl {
    // Try different possible field names from backend
    return widget.restaurant['imageUrl'] ?? 
           widget.restaurant['photo_url'] ?? 
           widget.restaurant['image_url'] ??
           widget.restaurant['photoUrl'];
  }

  // Check if image URL is valid (not placeholder or empty)
  bool get _hasValidImage {
    final url = _imageUrl;
    if (url == null || url.isEmpty) return false;
    if (url == 'placeholder.jpg' || url == 'placeholder') return false;
    if (!url.startsWith('http')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  _buildImage(),

                  // Hover overlay effect
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Restaurant Info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_isHovered ? AppSpacing.md : AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Restaurant Name
                          Text(
                            widget.restaurant['name'] ?? 'Restaurant',
                            style: AppTextStyles.bodyEmphasized.copyWith(
                              color: AppColors.baseWhite,
                              fontSize: _isHovered ? 20 : 18,
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
                          
                          // Business type and rating row
                          Row(
                            children: [
                              // Rating badge
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
                                      color: Color(0xFFFFC107),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (widget.restaurant['rating'] ?? 4.5).toString(),
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.baseWhite,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Business type
                              if (widget.restaurant['business_type'] != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.restaurant['business_type'],
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.baseWhite.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          // Show "View Menu" on hover
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD70F64),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'View Menu →',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  Widget _buildImage() {
    if (_hasValidImage) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // Use a nice gradient background with restaurant icon for missing images
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              widget.restaurant['name'] ?? '',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
