import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model Downloader class (your existing code)
class ModelDownloader {
  static const String _modelUrlSmall =
      'https://huggingface.co/HuggingFaceTB/SmolVLM-256M/resolve/main/model-optimized.tflite';
  static const String _modelUrlMedium =
      'https://huggingface.co/HuggingFaceTB/SmolVLM-500M/resolve/main/model-optimized.tflite';

  static const String _prefKeyModelDownloaded = 'model_downloaded';
  static const String _prefKeyModelPath = 'model_path';
  static const String _prefKeyModelSize = 'model_size';

  // Check if model is already downloaded
  static Future<bool> isModelDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool downloaded = prefs.getBool(_prefKeyModelDownloaded) ?? false;
    if (downloaded) {
      final String? modelPath = prefs.getString(_prefKeyModelPath);
      if (modelPath != null) {
        final file = File(modelPath);
        return await file.exists();
      }
    }
    return false;
  }

  // Get the size of the downloaded model
  static Future<String?> getModelSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyModelSize);
  }

  // Get the path to the downloaded model
  static Future<String?> getModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyModelPath);
  }

  // Download the model
  static Future<String?> downloadModel({
    required String size,
    Function(double)? onProgress,
  }) async {
    try {
      // Select URL based on model size
      final String modelUrl =
          size == 'small' ? _modelUrlSmall : _modelUrlMedium;

      debugPrint('🌐 Downloading model from: $modelUrl');

      // Create a request for the URL
      final request = http.Request('GET', Uri.parse(modelUrl));
      final streamedResponse = await http.Client().send(request);

      // Check for valid response
      if (streamedResponse.statusCode != 200) {
        debugPrint(
            '❌ Failed to download model: ${streamedResponse.statusCode}');
        return null;
      }

      // Get content length for progress reporting
      final contentLength = streamedResponse.contentLength ?? 0;

      // Get the app's documents directory for storing the model
      final appDir = await getApplicationDocumentsDirectory();
      final modelFileName = 'smolvlm_${size}_model.tflite';
      final modelFile = File('${appDir.path}/$modelFileName');

      // Create file writer
      final sink = modelFile.openWrite();
      var bytesReceived = 0;

      // Stream the download and update progress
      await for (var chunk in streamedResponse.stream) {
        sink.add(chunk);
        bytesReceived += chunk.length;

        if (onProgress != null && contentLength > 0) {
          final progress = bytesReceived / contentLength;
          onProgress(progress);
        }
      }

      // Close the file
      await sink.close();

      // Save the model path in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyModelDownloaded, true);
      await prefs.setString(_prefKeyModelPath, modelFile.path);
      await prefs.setString(_prefKeyModelSize, size);

      debugPrint('✅ Model downloaded successfully to: ${modelFile.path}');

      return modelFile.path;
    } catch (e) {
      debugPrint('❌ Error downloading model: $e');
      return null;
    }
  }
}

// Widget to show model download status and controls
class ModelDownloadWidget extends StatefulWidget {
  final Function(String?)? onModelReady;

  const ModelDownloadWidget({
    Key? key,
    this.onModelReady,
  }) : super(key: key);

  @override
  _ModelDownloadWidgetState createState() => _ModelDownloadWidgetState();
}

class _ModelDownloadWidgetState extends State<ModelDownloadWidget> {
  bool _isModelDownloaded = false;
  String? _downloadedModelSize;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _selectedSize = 'small'; // Default to small model

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  // Check if model is already downloaded
  Future<void> _checkModelStatus() async {
    final isDownloaded = await ModelDownloader.isModelDownloaded();
    final size = await ModelDownloader.getModelSize();

    setState(() {
      _isModelDownloaded = isDownloaded;
      _downloadedModelSize = size;
    });

    if (isDownloaded && widget.onModelReady != null) {
      final modelPath = await ModelDownloader.getModelPath();
      widget.onModelReady!(modelPath);
    }
  }

  // Update download progress
  void _updateProgress(double progress) {
    setState(() {
      _downloadProgress = progress;
    });
  }

  // Start model download
  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final modelPath = await ModelDownloader.downloadModel(
      size: _selectedSize,
      onProgress: _updateProgress,
    );

    setState(() {
      _isDownloading = false;
      _isModelDownloaded = modelPath != null;
      if (modelPath != null) {
        _downloadedModelSize = _selectedSize;
      }
    });

    if (modelPath != null && widget.onModelReady != null) {
      widget.onModelReady!(modelPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SmolVLM Model',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Model status
            if (_isModelDownloaded && !_isDownloading)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Model downloaded (${_downloadedModelSize == 'small' ? '256M' : '500M'})',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else if (!_isDownloading)
              Text(
                'No model downloaded',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),

            const SizedBox(height: 16),

            // Download progress
            if (_isDownloading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downloading ${_selectedSize == 'small' ? '256M' : '500M'} model...',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 4),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

            if (!_isDownloading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select model size:',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),

                  // Model size selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(
                            '256M (Smaller)',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          value: 'small',
                          groupValue: _selectedSize,
                          onChanged: (value) {
                            setState(() {
                              _selectedSize = value!;
                            });
                          },
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(
                            '500M (Better)',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          value: 'medium',
                          groupValue: _selectedSize,
                          onChanged: (value) {
                            setState(() {
                              _selectedSize = value!;
                            });
                          },
                          dense: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Download button
                  Center(
                    child: ElevatedButton(
                      onPressed: _downloadModel,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isModelDownloaded
                            ? 'Download Different Model'
                            : 'Download Model',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
