import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });

    if (_isCameraPermissionGranted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Copy the captured image to a temporary file
      final File imageFile = File(image.path);
      await imageFile.copy(imagePath);

      if (mounted) {
        // Return to previous screen with the image path
        Navigator.pop(context, imagePath);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Camera permission is required'),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Request Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: deviceSize.width,
                height: deviceSize.height,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // Rectangular overlay guide
          Center(
            child: Container(
              width: deviceSize.width * 0.8,
              height: deviceSize.height * 0.3,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 3.0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Return to previous screen button
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                color: Colors.grey, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Camera control
          Positioned(
            right: 20,
            bottom: deviceSize.height * 0.5 - 25,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),

          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: deviceSize.width * 0.4,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position tiles inside the rectangle',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
