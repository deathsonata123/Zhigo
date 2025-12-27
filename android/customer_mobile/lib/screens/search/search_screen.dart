import 'package:flutter/material.dart';
import '../../widgets/floating_bottom_nav.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
  static const Color background = Color(0xFFF8F8F8);
}

/// Search Screen with recent searches, categories, results, and no results states
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<String> _recentSearches = [
    'Margherita Pizza',
    'Fresh Avocados',
    'Organic Milk',
  ];

  final List<String> _categories = ['Food', 'Grocery', 'Medicine'];

  // Mock search results
  final List<Map<String, dynamic>> _allItems = [
    {'name': 'Margherita Pizza', 'restaurant': 'Pizza Palace', 'price': 14.99},
    {'name': 'Pepperoni Pizza', 'restaurant': 'Pizza Palace', 'price': 16.50},
    {'name': 'Vegan Supreme', 'restaurant': 'Green Delight', 'price': 18.00},
    {'name': 'BBQ Chicken Pizza', 'restaurant': "Smokey's Joint", 'price': 17.25},
    {'name': 'Hawaiian Pizza', 'restaurant': 'Island Bites', 'price': 15.75},
    {'name': 'Fresh Avocados', 'restaurant': 'Fresh Mart', 'price': 5.99},
    {'name': 'Organic Milk', 'restaurant': 'Dairy Farm', 'price': 3.49},
  ];

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = _allItems.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final restaurant = (item['restaurant'] as String).toLowerCase();
        return name.contains(query) || restaurant.contains(query);
      }).toList();
    });
  }

  void _onSearchSubmit() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  void _searchFromRecent(String query) {
    _searchController.text = query;
    _onSearchChanged();
  }

  void _searchCategory(String category) {
    _searchController.text = category;
    _onSearchChanged();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _hasSearched = false;
      _searchResults = [];
    });
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),
            
            // Content
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : _buildInitialContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          if (_isSearching)
            GestureDetector(
              onTap: _clearSearch,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_back, size: 24),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _FoodpandaColors.grey100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: _FoodpandaColors.grey500,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _onSearchSubmit(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: _FoodpandaColors.grey900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search food, groceries...',
                        hintStyle: TextStyle(
                          color: _FoodpandaColors.grey500,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        Icons.cancel,
                        size: 20,
                        color: _FoodpandaColors.grey500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _CancelButton(onTap: _cancel),
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _FoodpandaColors.grey900,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_recentSearches.length, (index) {
              return _RecentSearchItem(
                text: _recentSearches[index],
                onTap: () => _searchFromRecent(_recentSearches[index]),
                onRemove: () => _removeRecentSearch(index),
              );
            }),
            const SizedBox(height: 32),
          ],
          
          // Top Categories
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((category) {
              return _CategoryPill(
                text: category,
                onTap: () => _searchCategory(category),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _hasSearched) {
      return _buildNoResults();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _SearchResultItem(
          name: item['name'] as String,
          restaurant: item['restaurant'] as String,
          price: item['price'] as double,
          onTap: () {
            // TODO: Navigate to item or restaurant
          },
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: _FoodpandaColors.grey300,
          ),
          const SizedBox(height: 24),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Sorry, we couldn't find any items or stores. Please try a different search.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _FoodpandaColors.grey600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cancel Button
class _CancelButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'Cancel',
          style: TextStyle(
            fontSize: 16,
            color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Recent Search Item
class _RecentSearchItem extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchItem({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_RecentSearchItem> createState() => _RecentSearchItemState();
}

class _RecentSearchItemState extends State<_RecentSearchItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.grey100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 22,
                color: _FoodpandaColors.grey500,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: _FoodpandaColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Category Pill
class _CategoryPill extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.text,
    required this.onTap,
  });

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.coralLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey300,
              width: 1,
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _FoodpandaColors.coral,
            ),
          ),
        ),
      ),
    );
  }
}

// Search Result Item
class _SearchResultItem extends StatefulWidget {
  final String name;
  final String restaurant;
  final double price;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.onTap,
  });

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: _isHovered ? _FoodpandaColors.grey100 : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _FoodpandaColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'from ${widget.restaurant}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _FoodpandaColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _FoodpandaColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
