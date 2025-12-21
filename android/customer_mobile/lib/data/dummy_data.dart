// Dummy data for restaurant listings and featured dishes

class DummyData {
  // Featured dishes shown in carousel
  static const List<Map<String, String>> featuredDishes = [
    {
      'name': 'Gourmet Pizza',
      'description': 'Freshly baked with premium ingredients',
      'imageUrl': 'https://picsum.photos/seed/dish1/800/600',
    },
    {
      'name': 'Spicy Tacos',
      'description': 'A fiesta of flavors in every bite',
      'imageUrl': 'https://picsum.photos/seed/dish2/800/600',
    },
    {
      'name': 'Fresh Sushi Rolls',
      'description': 'Authentic Japanese delight',
      'imageUrl': 'https://picsum.photos/seed/dish3/800/600',
    },
    {
      'name': 'Juicy Burgers',
      'description': 'Classic American comfort food',
      'imageUrl': 'https://picsum.photos/seed/dish4/800/600',
    },
    {
      'name': 'Creamy Pasta',
      'description': 'An Italian masterpiece',
      'imageUrl': 'https://picsum.photos/seed/dish5/800/600',
    },
  ];

  // Dummy restaurants for when API is loading or fails
  static final List<Map<String, dynamic>> dummyRestaurants = [
    {
      'id': 'dummy1',
      'name': 'The Golden Spoon',
      'address': 'Downtown Food District, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant1/600/400',
      'rating': 4.8,
      'deliveryTime': '25-35 min',
      'category': 'Italian',
      'priceRange': '\$\$',
    },
    {
      'id': 'dummy2',
      'name': 'Burger Paradise',
      'address': 'Gulshan Avenue, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant2/600/400',
      'rating': 4.5,
      'deliveryTime': '20-30 min',
      'category': 'American',
      'priceRange': '\$',
    },
    {
      'id': 'dummy3',
      'name': 'Sushi Master',
      'address': 'Banani, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant3/600/400',
      'rating': 4.9,
      'deliveryTime': '30-40 min',
      'category': 'Japanese',
      'priceRange': '\$\$\$',
    },
    {
      'id': 'dummy4',
      'name': 'Taco Fiesta',
      'address': 'Dhanmondi, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant4/600/400',
      'rating': 4.6,
      'deliveryTime': '15-25 min',
      'category': 'Mexican',
      'priceRange': '\$',
    },
    {
      'id': 'dummy5',
      'name': 'Pasta Palace',
      'address': 'Uttara, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant5/600/400',
      'rating': 4.7,
      'deliveryTime': '25-35 min',
      'category': 'Italian',
      'priceRange': '\$\$',
    },
    {
      'id': 'dummy6',
      'name': 'BBQ House',
      'address': 'Mirpur, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant6/600/400',
      'rating': 4.4,
      'deliveryTime': '30-40 min',
      'category': 'BBQ',
      'priceRange': '\$\$',
    },
    {
      'id': 'dummy7',
      'name': 'Noodle Bar',
      'address': 'Mohakhali, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant7/600/400',
      'rating': 4.3,
      'deliveryTime': '20-30 min',
      'category': 'Asian',
      'priceRange': '\$',
    },
    {
      'id': 'dummy8',
      'name': 'The Steakhouse',
      'address': 'Gulshan 2, Dhaka',
      'imageUrl': 'https://picsum.photos/seed/restaurant8/600/400',
      'rating': 4.9,
      'deliveryTime': '35-45 min',
      'category': 'Steakhouse',
      'priceRange': '\$\$\$',
    },
  ];
}
