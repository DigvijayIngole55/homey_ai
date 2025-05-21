import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/text_styles.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the tertiary color (amber/gold) for nutrition screen to maintain theme consistency
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.tertiary;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar - Made consistent with other screens
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 60,
              title: Text(
                'Nutrition',
                style: AppTextStyles.screenTitleStyle,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_today_outlined,
                      color: colorScheme.onBackground),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onBackground),
                  onPressed: () {},
                ),
              ],
            ),

            // Today's Nutrition Header - Styled consistently with other screens
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Nutrition",
                          style: AppTextStyles.sectionTitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(DateTime.now()),
                          style: AppTextStyles.captionStyle,
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Simplified Nutrition Stats - Horizontal layout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleNutritionStat("1870", "cal",
                        Icons.local_fire_department_rounded, accentColor),
                    _buildSimpleNutritionStat("65g", "prot",
                        Icons.fitness_center_rounded, Colors.blue),
                    _buildSimpleNutritionStat(
                        "220g", "carb", Icons.grain_rounded, Colors.green),
                    _buildSimpleNutritionStat(
                        "58g", "fat", Icons.opacity_rounded, Colors.orange),
                  ],
                ),
              ),
            ),

            // Today's Meals Title - Using consistent header styling
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "TODAY'S MEALS",
                  style: AppTextStyles.sectionTitleStyle,
                ),
              ),
            ),

            // Meals List - Updated with consistent card styling
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mealData = [
                    {
                      'mealType': 'Breakfast',
                      'time': '7:30 AM',
                      'foodItems': 'Oatmeal, Banana, Coffee',
                      'calories': 320,
                    },
                    {
                      'mealType': 'Lunch',
                      'time': '12:15 PM',
                      'foodItems': 'Chicken Salad, Whole Grain Bread, Apple',
                      'calories': 450,
                    },
                    {
                      'mealType': 'Snack',
                      'time': '3:00 PM',
                      'foodItems': 'Greek Yogurt, Almonds',
                      'calories': 250,
                    },
                    {
                      'mealType': 'Dinner',
                      'time': '6:45 PM',
                      'foodItems': 'Salmon, Brown Rice, Broccoli',
                      'calories': 520,
                    },
                    {
                      'mealType': 'Snack',
                      'time': '9:00 PM',
                      'foodItems': 'Dark Chocolate, Berries',
                      'calories': 180,
                    },
                  ];

                  if (index < mealData.length) {
                    final meal = mealData[index];
                    return _buildMealCard(
                      context,
                      meal['mealType'] as String,
                      meal['time'] as String,
                      meal['foodItems'] as String,
                      meal['calories'] as int,
                      accentColor,
                    );
                  }
                  return null;
                },
                childCount: 5,
              ),
            ),

            // Calorie Breakdown Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CALORIE BREAKDOWN",
                      style: AppTextStyles.sectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daily Goal',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '1870 / 2000 cal',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.94,
                              backgroundColor: Colors.grey[800],
                              color: accentColor,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.analytics_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                        label: Text(
                          'View Nutrition Report',
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom space for better scrolling
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleNutritionStat(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast_rounded;
      case 'Lunch':
        return Icons.lunch_dining_rounded;
      case 'Dinner':
        return Icons.dinner_dining_rounded;
      case 'Snack':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Widget _buildMealCard(
    BuildContext context,
    String mealType,
    String time,
    String foodItems,
    int calories,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(mealType),
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodItems,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '$calories cal',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
