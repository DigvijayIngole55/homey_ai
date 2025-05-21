import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantryItem {
  final String name;
  final String quantity;
  final String expiresOn;
  final String category;
  final bool isExpiring;

  PantryItem({
    required this.name,
    required this.quantity,
    required this.expiresOn,
    required this.category,
    this.isExpiring = false,
  });
}

class PantryScreen extends StatefulWidget {
  const PantryScreen({Key? key}) : super(key: key);

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Expiring Soon',
    'Dairy',
    'Produce',
    'Meat',
    'Grains',
    'Bakery',
  ];

  final List<PantryItem> _pantryItems = [
    PantryItem(
      name: 'Milk',
      quantity: 'Qty: 1 gallon',
      expiresOn: 'Expires: May 21',
      category: 'Dairy',
      isExpiring: true,
    ),
    PantryItem(
      name: 'Chicken Breast',
      quantity: 'Qty: 1.5 lbs',
      expiresOn: 'Expires: May 22',
      category: 'Meat',
      isExpiring: true,
    ),
    PantryItem(
      name: 'Eggs',
      quantity: 'Qty: 8 large',
      expiresOn: 'Expires: May 30',
      category: 'Dairy',
    ),
    PantryItem(
      name: 'Apples',
      quantity: 'Qty: 4',
      expiresOn: 'Expires: May 25',
      category: 'Produce',
    ),
    PantryItem(
      name: 'Bread',
      quantity: 'Qty: 1 loaf',
      expiresOn: 'Expires: May 24',
      category: 'Bakery',
    ),
    PantryItem(
      name: 'Rice',
      quantity: 'Qty: 2 lbs',
      expiresOn: 'Expires: Dec 2025',
      category: 'Grains',
    ),
  ];

  List<PantryItem> get filteredItems {
    if (_selectedCategory == 'All') {
      return _pantryItems;
    } else if (_selectedCategory == 'Expiring Soon') {
      return _pantryItems.where((item) => item.isExpiring).toList();
    } else {
      return _pantryItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the secondary color (green) for the pantry screen
    final secondaryColor =
        Theme.of(context).colorScheme.secondary; // Green color

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF121212),
              title: const Text(
                'Pantry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPantryStatus(secondaryColor),
                    const SizedBox(height: 24),
                    _buildCategoryFilter(secondaryColor),
                    const SizedBox(height: 16),
                    if (_selectedCategory == 'Expiring Soon')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'EXPIRING SOON',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (_selectedCategory == 'All')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'ALL ITEMS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPantryItemCard(filteredItems[index]);
                },
                childCount: filteredItems.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: secondaryColor, // Green fab instead of purple
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPantryStatus(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantry Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have 32 items in your pantry',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2), // Green background
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_rounded,
              color: themeColor, // Green icon
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(Color themeColor) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor:
                  themeColor.withOpacity(0.2), // Green background when selected
              labelStyle: TextStyle(
                color: isSelected
                    ? themeColor
                    : Colors.grey[400], // Green text when selected
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPantryItemCard(PantryItem item) {
    Color categoryColor;
    IconData trailingIcon;

    switch (item.category) {
      case 'Dairy':
        categoryColor = const Color(0xFF3B82F6);
        trailingIcon = Icons.arrow_forward_ios_rounded;
        break;
      case 'Meat':
        categoryColor = const Color(0xFFEF4444);
        trailingIcon = Icons.arrow_forward_ios_rounded;
        break;
      case 'Produce':
        categoryColor = const Color(0xFF10B981);
        trailingIcon = Icons.arrow_forward_ios_rounded;
        break;
      case 'Grains':
        categoryColor = const Color(0xFFF59E0B);
        trailingIcon = Icons.arrow_forward_ios_rounded;
        break;
      case 'Bakery':
        categoryColor = const Color(0xFFF97316);
        trailingIcon = Icons.arrow_forward_ios_rounded;
        break;
      default:
        categoryColor = const Color(0xFF8B5CF6);
        trailingIcon = Icons.arrow_forward_ios_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        elevation: 0,
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.isExpiring)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFEF4444),
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item.quantity,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.expiresOn,
                          style: TextStyle(
                            fontSize: 14,
                            color: item.isExpiring
                                ? const Color(0xFFEF4444)
                                : Colors.grey[400],
                            fontWeight: item.isExpiring
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: categoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                trailingIcon,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
