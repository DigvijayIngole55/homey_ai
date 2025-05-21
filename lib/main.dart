import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pantry_screen.dart';
import 'nutrition_screen.dart';
import 'expenses_screen.dart';
import 'camera_screen.dart';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homey AI',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFF60A5FA),
          tertiary: const Color(0xFF34D399),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // Remove PageController since we're not using a PageView
  // Instead, we'll use a simpler approach with AnimatedSwitcher

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    // Simply update the selected index without PageController
    setState(() {
      _selectedIndex = index;
    });

    // Play animation for feedback
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<Widget> screens = [
      HomeScreen(onNavTap: _onNavTap),
      PantryScreen(),
      const CameraScreen(),
      NutritionScreen(),
      const ExpensesScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(
              _selectedIndex), // Add a key for AnimatedSwitcher to detect changes
          child: screens[_selectedIndex],
        ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Only apply fancy transitions if not moving to/from camera
          if (_selectedIndex != 2 && screens[_selectedIndex] != screens[2]) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          } else {
            // Simple fade for camera
            return FadeTransition(opacity: animation, child: child);
          }
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: NavigationBar(
                height: 64,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavTap,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  _buildNavDestination(
                      0, Icons.home_rounded, 'Home', colorScheme.primary),
                  _buildNavDestination(1, Icons.shopping_basket_rounded,
                      'Pantry', colorScheme.secondary),
                  _buildCameraDestination(),
                  _buildNavDestination(3, Icons.restaurant_rounded, 'Nutrition',
                      colorScheme.tertiary),
                  _buildNavDestination(4, Icons.attach_money_rounded,
                      'Expenses', const Color(0xFFE879F9)), // Light purple
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(
      int index, IconData icon, String label, Color color) {
    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: _selectedIndex == index ? color : Colors.grey[600],
          size: 24,
        ),
      ),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      label: label,
    );
  }

  Widget _buildCameraDestination() {
    return NavigationDestination(
      icon: GestureDetector(
        onTap: () => _onNavTap(2),
        child: TweenAnimationBuilder<double>(
          tween:
              Tween<double>(begin: 1.0, end: _selectedIndex == 2 ? 1.1 : 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFA78BFA)
                    ], // Updated from blue to purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6)
                          .withOpacity(0.3), // Updated shadow
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            );
          },
        ),
      ),
      label: 'Camera',
    );
  }
}
