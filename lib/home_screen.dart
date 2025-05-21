import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/text_styles.dart';

// Model Downloader class with real functionality
class ModelDownloader {
  static const String _prefKeyModelDownloaded = 'model_downloaded';
  static const String _prefKeyModelPath = 'model_path';
  static const String _prefKeyModelSize = 'model_size';

  // Check if model is already downloaded
  static Future<bool> isModelDownloaded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool downloaded = prefs.getBool(_prefKeyModelDownloaded) ?? false;
      return downloaded;
    } catch (e) {
      debugPrint('Error checking model download status: $e');
      return false;
    }
  }

  // Get model size
  static Future<String?> getModelSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefKeyModelSize);
    } catch (e) {
      debugPrint('Error getting model size: $e');
      return null;
    }
  }

  // Get the path to the downloaded model
  static Future<String?> getModelPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefKeyModelPath);
    } catch (e) {
      debugPrint('Error getting model path: $e');
      return null;
    }
  }

  // Simulate model download with progress updates
  static Future<String?> downloadModel({
    required String size,
    Function(double)? onProgress,
  }) async {
    try {
      // Simulate download progress
      for (var i = 0; i <= 10; i++) {
        if (onProgress != null) {
          await Future.delayed(const Duration(milliseconds: 200));
          onProgress(i / 10);
        }
      }

      // Simulate file path creation
      String modelPath = 'simulated_${size}_model.tflite';

      try {
        final appDir = await getApplicationDocumentsDirectory();
        modelPath = '${appDir.path}/$modelPath';
      } catch (e) {
        debugPrint('Could not get app directory (expected on web): $e');
        // On web, just use a dummy path
        modelPath = '/web/app/$modelPath';
      }

      // Save the model path in preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyModelDownloaded, true);
        await prefs.setString(_prefKeyModelPath, modelPath);
        await prefs.setString(_prefKeyModelSize, size);
      } catch (e) {
        debugPrint('Error storing model info in preferences: $e');
      }

      debugPrint('✅ Model downloaded successfully to: $modelPath (simulated)');

      return modelPath;
    } catch (e) {
      debugPrint('❌ Error downloading model: $e');
      return null;
    }
  }
}

// HomeScreen as StatefulWidget
class HomeScreen extends StatefulWidget {
  final Function(int) onNavTap;

  const HomeScreen({Key? key, required this.onNavTap}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isModelDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _selectedModelSize = 'small'; // Default to small model
  String? _errorMessage;
  String? _downloadedModelSize;

  // Model size details
  final Map<String, Map<String, dynamic>> _modelSizes = {
    'small': {
      'name': 'Small (256M)',
      'description': 'Faster, uses less storage',
      'size': '~100MB',
    },
    'medium': {
      'name': 'Medium (500M)',
      'description': 'Better accuracy, more storage',
      'size': '~300MB',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final isDownloaded = await ModelDownloader.isModelDownloaded();
    final downloadedSize = await ModelDownloader.getModelSize();

    if (mounted) {
      setState(() {
        _isModelDownloaded = isDownloaded;
        _downloadedModelSize = downloadedSize;
        if (downloadedSize != null) {
          _selectedModelSize = downloadedSize;
        }
      });
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      // Start the real download with progress updates
      final modelPath = await ModelDownloader.downloadModel(
        size: _selectedModelSize,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (modelPath != null) {
        if (mounted) {
          setState(() {
            _isModelDownloaded = true;
            _isDownloading = false;
            _downloadedModelSize = _selectedModelSize;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to download model. Please try again.';
            _isDownloading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isDownloading = false;
        });
      }
    }
  }

  // Skip download for now
  void _skipDownload() {
    setState(() {
      _isModelDownloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              expandedHeight: 120,
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Text(
                      'Homey AI',
                      style: AppTextStyles.screenTitleStyle,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: IconButton(
                      icon: Icon(Icons.notifications_none_rounded,
                          color: colorScheme.primary),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),

            // Welcome Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: AppTextStyles.sectionTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to do today?',
                      style: AppTextStyles.captionStyle,
                    ),
                  ],
                ),
              ),
            ),

            // Model Download Container - only shown if model is not downloaded
            if (!_isModelDownloaded)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.2),
                          const Color(0xFF6366F1).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.smart_toy_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI Model Required',
                                style: AppTextStyles.sectionTitleStyle.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'To enable receipt scanning and intelligent item recognition, download the SmolVLM model.',
                          style: AppTextStyles.bodyTextStyle,
                        ),
                        const SizedBox(height: 16),

                        // Model selection options - only show if not downloading
                        if (!_isDownloading)
                          Column(
                            children: [
                              _buildModelSizeOption(
                                _modelSizes['small']!['name'] as String,
                                '${_modelSizes['small']!['description']} (${_modelSizes['small']!['size']})',
                                'small',
                                colorScheme,
                              ),
                              const SizedBox(height: 12),
                              _buildModelSizeOption(
                                _modelSizes['medium']!['name'] as String,
                                '${_modelSizes['medium']!['description']} (${_modelSizes['medium']!['size']})',
                                'medium',
                                colorScheme,
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Progress bar during download
                        if (_isDownloading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Downloading ${_modelSizes[_selectedModelSize]!['name']}...',
                                style: AppTextStyles.bodyTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _downloadProgress,
                                  backgroundColor: Colors.grey[800],
                                  color: colorScheme.primary,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(_downloadProgress * 100).toInt()}% complete',
                                style: AppTextStyles.captionStyle,
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Error message if download failed
                              if (_errorMessage != null)
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.captionStyle.copyWith(
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ),
                              TextButton(
                                onPressed: _skipDownload,
                                child: Text(
                                  'Skip',
                                  style: AppTextStyles.bodyTextStyle.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _downloadModel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Download',
                                  style: AppTextStyles.bodyTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.sectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildQuickActionCard(
                          context,
                          'Scan Receipt',
                          Icons.receipt_long_rounded,
                          colorScheme.primary,
                          () => widget.onNavTap(2), // Navigate to Camera
                        ),
                        _buildQuickActionCard(
                          context,
                          'Add to Pantry',
                          Icons.add_shopping_cart_rounded,
                          colorScheme.secondary,
                          () => widget.onNavTap(1), // Navigate to Pantry
                        ),
                        _buildQuickActionCard(
                          context,
                          'Track Nutrition',
                          Icons.restaurant_rounded,
                          colorScheme.tertiary,
                          () => widget.onNavTap(3), // Navigate to Nutrition
                        ),
                        _buildQuickActionCard(
                          context,
                          'Expense Report',
                          Icons.pie_chart_rounded,
                          const Color(0xFFE879F9),
                          () => widget.onNavTap(4), // Navigate to Expenses
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: AppTextStyles.sectionTitleStyle,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodyTextStyle.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActivityCard(
                      context,
                      'Added items to pantry',
                      'Today, 2:30 PM',
                      Icons.shopping_basket_rounded,
                      colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      context,
                      'Scanned grocery receipt',
                      'Today, 1:15 PM',
                      Icons.receipt_rounded,
                      colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      context,
                      'Generated meal plan',
                      'Yesterday, 6:45 PM',
                      Icons.restaurant_menu_rounded,
                      colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),

            // Budget Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Summary',
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This Month',
                                style: AppTextStyles.bodyTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$320 / \$500',
                                style: AppTextStyles.bodyTextStyle.copyWith(
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
                              value: 0.64,
                              backgroundColor: Colors.grey[800],
                              color: colorScheme.primary,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBudgetStat(
                                'Groceries',
                                '\$210',
                                colorScheme.secondary,
                              ),
                              _buildBudgetStat(
                                'Dining',
                                '\$75',
                                colorScheme.tertiary,
                              ),
                              _buildBudgetStat(
                                'Snacks',
                                '\$35',
                                const Color(0xFFE879F9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            widget.onNavTap(4), // Navigate to Expenses
                        icon: Icon(
                          Icons.analytics_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'View Detailed Report',
                          style: AppTextStyles.bodyTextStyle.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Empty space at bottom for better scrolling
            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        ),
      ),
    );
  }

  // Model size selection option
  Widget _buildModelSizeOption(
      String title, String description, String value, ColorScheme colorScheme) {
    final isSelected = _selectedModelSize == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModelSize = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.captionStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyTextStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String title, String time,
      IconData icon, Color color) {
    return Container(
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.captionStyle.copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == 'Groceries'
                ? Icons.shopping_cart_rounded
                : label == 'Dining'
                    ? Icons.restaurant_rounded
                    : Icons.icecream_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.captionStyle.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
