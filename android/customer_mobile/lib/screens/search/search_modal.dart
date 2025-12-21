import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/minimalist_restaurant_card.dart';
import '../../data/dummy_data.dart';
import '../restaurant/restaurant_details_screen.dart';

/// Search Modal - Full-screen modal with smooth transition
/// Morphing animation from static search bar
class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    
    // Smooth entry animation (300-400ms ease out)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
    
    // Auto-focus keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Search in dummy data
    final results = DummyData.dummyRestaurants.where((restaurant) {
      final name = restaurant['name'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _closeModal() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeModal();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Search Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
                    child: Row(
                      children: [
                        // Cancel Button
                        IconButton(
                          onPressed: _closeModal,
                          icon: const Icon(Icons.arrow_back),
                          color: AppColors.textPrimary,
                        ),
                        
                        const SizedBox(width: AppSpacing.xs),
                        
                        // Search Input
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: _performSearch,
                            style: AppTextStyles.bodyPrimary,
                            decoration: InputDecoration(
                              hintText: 'Search restaurants...',
                              hintStyle: AppTextStyles.bodyPrimary.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Search Results
                  Expanded(
                    child: _isSearching
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          )
                        : _searchResults.isEmpty && _searchController.text.isNotEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: AppColors.textSecondary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'No restaurants found',
                                      style: AppTextStyles.bodyPrimary.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _searchController.text.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.restaurant_menu_rounded,
                                          size: 64,
                                          color: AppColors.textSecondary.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          'Start typing to search',
                                          style: AppTextStyles.bodyPrimary.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: AppSpacing.sm,
                                      mainAxisSpacing: AppSpacing.sm,
                                    ),
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final restaurant = _searchResults[index];
                                      return MinimalistRestaurantCard(
                                        restaurant: restaurant,
                                        onTap: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => RestaurantDetailsFullScreen(
                                                restaurantId: restaurant['id'].toString(),
                                                restaurant: restaurant,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
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
}
