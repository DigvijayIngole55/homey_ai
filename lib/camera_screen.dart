import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/text_styles.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  File? _imageFile;
  bool _isAnalyzing = false;
  bool _flashEnabled = false;

  // Camera initialization
  Future<void> _initCamera() async {
    debugPrint('🎥 Starting camera initialization...');

    // Check and request camera permission
    final status = await Permission.camera.request();
    debugPrint('📱 Camera permission status: ${status.toString()}');

    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    debugPrint('🔐 Is camera permission granted? $_isCameraPermissionGranted');

    if (!_isCameraPermissionGranted) {
      debugPrint('❌ Camera permission denied, returning early');
      return;
    }

    // Get available cameras
    try {
      debugPrint('📸 Fetching available cameras...');
      _cameras = await availableCameras();
      debugPrint('📸 Number of cameras found: ${_cameras.length}');

      // Initialize camera controller
      if (_cameras.isNotEmpty) {
        debugPrint('🎥 Setting up camera controller...');
        _cameraController = CameraController(
          _isRearCameraSelected ? _cameras[0] : _cameras[1],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.yuv420
              : ImageFormatGroup.bgra8888,
        );

        debugPrint('🎥 Initializing camera controller...');
        await _cameraController!.initialize();
        debugPrint('✅ Camera controller initialized successfully');

        setState(() {
          _isCameraInitialized = true;
        });
        debugPrint('📱 Camera UI should now be visible');
      } else {
        debugPrint('❌ No cameras available on device');
      }
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _flashEnabled = !_flashEnabled;
      });

      await _cameraController!.setFlashMode(
        _flashEnabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Take a picture
      final image = await _cameraController!.takePicture();
      setState(() {
        _imageFile = File(image.path);
        _isAnalyzing = true;
      });

      // Simulate receipt analysis (would connect to ML service in real app)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isAnalyzing = false;
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isAnalyzing = true;
      });

      // Simulate receipt analysis
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isAnalyzing = false;
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Receipt Scanned Successfully',
            style: AppTextStyles.screenTitleStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF8B5CF6),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Your receipt has been processed!',
                style: AppTextStyles.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '• 6 items detected\n• Total: \$42.68\n• Added to your expenses',
                style: AppTextStyles.bodyTextStyle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _imageFile = null;
                });
              },
              child: Text(
                'Back to Camera',
                style: AppTextStyles.captionStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Here you would navigate to expenses screen
                setState(() {
                  _imageFile = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: Text(
                'View Details',
                style: AppTextStyles.captionStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleCameraDirection() async {
    if (_cameraController == null || _cameras.length < 2) {
      return;
    }

    setState(() {
      _isCameraInitialized = false;
      _isRearCameraSelected = !_isRearCameraSelected;
    });

    await _cameraController!.dispose();

    _cameraController = CameraController(
      _isRearCameraSelected ? _cameras[0] : _cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  @override
  void initState() {
    debugPrint('🚀 CameraScreen initState called');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    debugPrint('🔥 CameraScreen dispose called');
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle state changed to: $state');
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint(
          '❌ Camera controller not initialized, skipping lifecycle handling');
      return;
    }

    if (state == AppLifecycleState.inactive) {
      debugPrint('📱 App inactive, disposing camera controller');
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed, reinitializing camera');
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isAnalyzing) {
      return _buildAnalyzingScreen();
    }

    return _buildPermissionScreen();

    // return Scaffold(
    //   body: SafeArea(
    //     child: Stack(
    //       children: [
    //         // Camera preview
    //         if (_isCameraInitialized)
    //           Positioned.fill(
    //             child: AspectRatio(
    //               aspectRatio: _cameraController!.value.aspectRatio,
    //               child: CameraPreview(_cameraController!),
    //             ),
    //           )
    //         else
    //           const Positioned.fill(
    //             child: Center(
    //               child: CircularProgressIndicator(
    //                 color: Color(0xFF8B5CF6),
    //               ),
    //             ),
    //           ),

    //         // Top controls
    //         Positioned(
    //           top: 0,
    //           left: 0,
    //           right: 0,
    //           child: Container(
    //             padding:
    //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.topCenter,
    //                 end: Alignment.bottomCenter,
    //                 colors: [
    //                   Colors.black.withOpacity(0.7),
    //                   Colors.transparent,
    //                 ],
    //               ),
    //             ),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 // Back button
    //                 CircleAvatar(
    //                   backgroundColor: Colors.black45,
    //                   radius: 20,
    //                   child: IconButton(
    //                     icon: const Icon(
    //                       Icons.arrow_back,
    //                       color: Colors.white,
    //                       size: 20,
    //                     ),
    //                     onPressed: () {
    //                       Navigator.of(context).pop();
    //                     },
    //                   ),
    //                 ),

    //                 // Title
    //                 Text(
    //                   'Scan Receipt',
    //                   style: AppTextStyles.sectionTitleStyle,
    //                 ),

    //                 // Flash toggle
    //                 CircleAvatar(
    //                   backgroundColor: Colors.black45,
    //                   radius: 20,
    //                   child: IconButton(
    //                     icon: Icon(
    //                       _flashEnabled ? Icons.flash_on : Icons.flash_off,
    //                       color: Colors.white,
    //                       size: 20,
    //                     ),
    //                     onPressed: _toggleFlash,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),

    //         // Scan guide overlay
    //         Positioned.fill(
    //           child: Center(
    //             child: Container(
    //               width: MediaQuery.of(context).size.width * 0.8,
    //               height: MediaQuery.of(context).size.width * 1.1,
    //               decoration: BoxDecoration(
    //                 border: Border.all(
    //                   color: Colors.white.withOpacity(0.5),
    //                   width: 2,
    //                 ),
    //                 borderRadius: BorderRadius.circular(12),
    //               ),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   const Icon(
    //                     Icons.receipt_long,
    //                     color: Colors.white70,
    //                     size: 48,
    //                   ),
    //                   const SizedBox(height: 8),
    //                   Text(
    //                     'Align receipt within frame',
    //                     style: AppTextStyles.captionStyle,
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),

    //         // Bottom controls
    //         Positioned(
    //           bottom: 0,
    //           left: 0,
    //           right: 0,
    //           child: Container(
    //             padding:
    //                 const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.bottomCenter,
    //                 end: Alignment.topCenter,
    //                 colors: [
    //                   Colors.black.withOpacity(0.7),
    //                   Colors.transparent,
    //                 ],
    //               ),
    //             ),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
    //               children: [
    //                 // Gallery button
    //                 GestureDetector(
    //                   onTap: _pickImageFromGallery,
    //                   child: Container(
    //                     width: 50,
    //                     height: 50,
    //                     decoration: BoxDecoration(
    //                       color: Colors.black38,
    //                       borderRadius: BorderRadius.circular(12),
    //                       border: Border.all(
    //                         color: Colors.white30,
    //                         width: 1,
    //                       ),
    //                     ),
    //                     child: const Icon(
    //                       Icons.photo_library,
    //                       color: Colors.white,
    //                       size: 24,
    //                     ),
    //                   ),
    //                 ),

    //                 // Camera button
    //                 GestureDetector(
    //                   onTap: _takePicture,
    //                   child: Container(
    //                     width: 72,
    //                     height: 72,
    //                     decoration: BoxDecoration(
    //                       color: Colors.white,
    //                       shape: BoxShape.circle,
    //                       border: Border.all(
    //                         color: Colors.white38,
    //                         width: 3,
    //                       ),
    //                       boxShadow: [
    //                         BoxShadow(
    //                           color: Colors.black.withOpacity(0.3),
    //                           blurRadius: 10,
    //                         ),
    //                       ],
    //                     ),
    //                     child: const Center(
    //                       child: Icon(
    //                         Icons.camera_alt,
    //                         color: Colors.black,
    //                         size: 32,
    //                       ),
    //                     ),
    //                   ),
    //                 ),

    //                 // Flip camera button
    //                 GestureDetector(
    //                   onTap: _toggleCameraDirection,
    //                   child: Container(
    //                     width: 50,
    //                     height: 50,
    //                     decoration: BoxDecoration(
    //                       color: Colors.black38,
    //                       borderRadius: BorderRadius.circular(12),
    //                       border: Border.all(
    //                         color: Colors.white30,
    //                         width: 1,
    //                       ),
    //                     ),
    //                     child: const Icon(
    //                       Icons.flip_camera_ios,
    //                       color: Colors.white,
    //                       size: 24,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),

    //         // Info button for tips
    //         Positioned(
    //           top: 80,
    //           right: 20,
    //           child: CircleAvatar(
    //             backgroundColor: Colors.black45,
    //             radius: 20,
    //             child: IconButton(
    //               icon: const Icon(
    //                 Icons.info_outline,
    //                 color: Colors.white,
    //                 size: 20,
    //               ),
    //               onPressed: () {
    //                 _showTipsDialog(context);
    //               },
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildPermissionScreen() {
    debugPrint('🔐 Building receipt capture screen');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 80,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 24),
              Text(
                'Capture Receipt',
                style: AppTextStyles.screenTitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan your grocery receipts to track expenses and add items to your pantry.',
                style: AppTextStyles.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera button - Filled circle
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          debugPrint('📸 Take photo button pressed');
                          final picker = ImagePicker();
                          try {
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.camera);
                            if (pickedFile != null) {
                              setState(() {
                                _imageFile = File(pickedFile.path);
                                _isAnalyzing = true;
                              });

                              // Simulate receipt analysis
                              await Future.delayed(const Duration(seconds: 2));

                              setState(() {
                                _isAnalyzing = false;
                              });

                              if (mounted) {
                                _showSuccessDialog();
                              }

                              // Update permission state if camera was accessed
                              setState(() {
                                _isCameraPermissionGranted = true;
                              });
                            }
                          } catch (e) {
                            debugPrint('📸 Camera error: $e');
                            // If there's an error with permissions, let the user know
                            if (e.toString().contains('permission')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enable camera access in Settings to use this feature'),
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Take Photo',
                        style: AppTextStyles.captionStyle,
                      ),
                    ],
                  ),

                  // Gallery button - Outlined circle
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          debugPrint('🖼️ Upload from gallery button pressed');
                          final picker = ImagePicker();
                          try {
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _imageFile = File(pickedFile.path);
                                _isAnalyzing = true;
                              });

                              // Simulate receipt analysis
                              await Future.delayed(const Duration(seconds: 2));

                              setState(() {
                                _isAnalyzing = false;
                              });

                              if (mounted) {
                                _showSuccessDialog();
                              }
                            }
                          } catch (e) {
                            debugPrint('🖼️ Gallery error: $e');
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'From Gallery',
                        style: AppTextStyles.captionStyle,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  debugPrint('❌ Back button pressed');
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.captionStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing Receipt...',
              style: AppTextStyles.bodyTextStyle,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Scanning for items, prices, and totals',
                style: AppTextStyles.captionStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Scanning Tips',
            style: AppTextStyles.screenTitleStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipItem(
                Icons.straighten,
                'Keep the receipt flat and straight',
              ),
              _buildTipItem(
                Icons.wb_sunny_outlined,
                'Scan in good lighting conditions',
              ),
              _buildTipItem(
                Icons.crop_free,
                'Ensure the entire receipt is visible',
              ),
              _buildTipItem(
                Icons.touch_app,
                'Hold steady while capturing',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Got it',
                style: AppTextStyles.captionStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.captionStyle,
            ),
          ),
        ],
      ),
    );
  }
}
