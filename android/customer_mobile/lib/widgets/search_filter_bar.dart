import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onPriceFilterChanged;
  final Function(double) onRatingFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onPriceFilterChanged,
    required this.onRatingFilterChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPrice = 'all';
  double _selectedRating = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search restaurants...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
          
          const SizedBox(height: 12),
          
          // Filters Row
          Row(
            children: [
              // Price Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPrice,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Any Price'),
                        ),
                        DropdownMenuItem(
                          value: '\$',
                          child: Text('\$ (Under \$10)'),
                        ),
                        DropdownMenuItem(
                          value: '\$\$',
                          child: Text('\$\$ (\$10 - \$20)'),
                        ),
                        DropdownMenuItem(
                          value: '\$\$\$',
                          child: Text('\$\$\$ (Over \$20)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPrice = value!;
                        });
                        widget.onPriceFilterChanged(value!);
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Rating Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _selectedRating,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: const [
                        DropdownMenuItem(
                          value: 0.0,
                          child: Text('Any Rating'),
                        ),
                        DropdownMenuItem(
                          value: 4.5,
                          child: Text('4.5+ ⭐'),
                        ),
                        DropdownMenuItem(
                          value: 4.0,
                          child: Text('4.0+ ⭐'),
                        ),
                        DropdownMenuItem(
                          value: 3.5,
                          child: Text('3.5+ ⭐'),
                        ),
                        DropdownMenuItem(
                          value: 3.0,
                          child: Text('3.0+ ⭐'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRating = value!;
                        });
                        widget.onRatingFilterChanged(value!);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
