import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/text_styles.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Currency formatter
  final currencyFormatter =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  // Current month expenses
  final double currentMonthTotal = 425.68;
  final double lastMonthTotal = 489.25;
  final double budgetTotal = 500.00;

  // Category expenses for the pie chart
  final Map<String, Map<String, dynamic>> categoryExpenses = {
    'Dairy': {'amount': 85.30, 'color': Colors.blue},
    'Meat': {'amount': 120.45, 'color': Colors.red},
    'Produce': {'amount': 95.25, 'color': Colors.green},
    'Bakery': {'amount': 62.80, 'color': Colors.orange},
    'Frozen': {'amount': 45.12, 'color': Colors.cyan},
    'Other': {'amount': 16.76, 'color': Colors.grey},
  };

  // Recent transactions
  final List<Map<String, dynamic>> recentTransactions = [
    {
      'store': 'Kroger',
      'categories': ['Dairy', 'Produce', 'Meat'],
      'amount': 86.45,
      'date': 'Today',
    },
    {
      'store': 'Whole Foods',
      'categories': ['Organic', 'Produce', 'Bakery'],
      'amount': 54.32,
      'date': 'May 16',
    },
    {
      'store': 'Trader Joe\'s',
      'categories': ['Snacks', 'Frozen', 'Dairy'],
      'amount': 42.18,
      'date': 'May 14',
    },
    {
      'store': 'Farmer\'s Market',
      'categories': ['Produce', 'Meat'],
      'amount': 35.00,
      'date': 'May 13',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = const Color(0xFFE879F9); // Light purple for expenses

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 60,
              title: Row(
                children: [
                  Text(
                    'Expenses',
                    style: AppTextStyles.screenTitleStyle,
                  ),
                ],
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

            // Month Header
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
                          'May 2025',
                          style: AppTextStyles.screenTitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Food & Grocery Expenses',
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
                        Icons.attach_money_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Budget Progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: AppTextStyles.sectionTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: currentMonthTotal / budgetTotal,
                        backgroundColor: Colors.grey[800],
                        color: accentColor,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${currencyFormatter.format(currentMonthTotal)} / ${currencyFormatter.format(budgetTotal)}',
                          style: AppTextStyles.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMonthSummary(
                          'This Month',
                          currentMonthTotal,
                          accentColor,
                        ),
                        _buildMonthSummary(
                          'Last Month',
                          lastMonthTotal,
                          Colors.grey[400]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Monthly Breakdown Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'MONTHLY BREAKDOWN',
                  style: AppTextStyles.sectionTitleStyle,
                ),
              ),
            ),

            // Category Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  padding: const EdgeInsets.all(8),
                  children: categoryExpenses.entries.map((entry) {
                    return _buildCategoryItem(
                      entry.key,
                      entry.value['amount'] as double,
                      entry.value['color'] as Color,
                    );
                  }).toList(),
                ),
              ),
            ),

            // Recent Expenses Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'RECENT EXPENSES',
                  style: AppTextStyles.sectionTitleStyle,
                ),
              ),
            ),

            // Recent Transactions List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction = recentTransactions[index];
                  return _buildTransactionItem(
                    transaction['store'] as String,
                    transaction['categories'] as List<String>,
                    transaction['amount'] as double,
                    transaction['date'] as String,
                  );
                },
                childCount: recentTransactions.length,
              ),
            ),

            // Bottom space for better scrolling
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthSummary(String label, double amount, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionStyle,
        ),
        Text(
          currencyFormatter.format(amount),
          style: AppTextStyles.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String category, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: AppTextStyles.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String store,
    List<String> categories,
    double amount,
    String date,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store,
                    style: AppTextStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories.join(', '),
                    style: AppTextStyles.captionStyle,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(amount),
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.captionStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dairy':
        return Icons.egg_alt_outlined;
      case 'Meat':
        return Icons.restaurant_menu_rounded;
      case 'Produce':
        return Icons.eco_rounded;
      case 'Bakery':
        return Icons.bakery_dining_rounded;
      case 'Frozen':
        return Icons.ac_unit_rounded;
      case 'Other':
        return Icons.more_horiz_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}
