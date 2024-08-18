import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyDraw',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isFlashOn = false;
  bool _isStrobeActive = false;
  int _strobeInterval = 500; // milliseconds
  XFile? _imageFile; // To hold the selected image
  double _imageOpacity = 0.5; // Initial opacity value
  double _imageScale = 1.0; // Initial scale value
  Offset _imagePosition = Offset(100, 100); // Initial position of the image
  bool _showGrid = false; // Flag to control grid visibility

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    initCamera();
    // Lock the orientation to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Reset orientation to allow other orientations
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> initCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.high,enableAudio: false);
    await _controller?.initialize();
    setState(() {});
  }

  void toggleFlash() async {
    if (_isFlashOn) {
      await _controller?.setFlashMode(FlashMode.off);
    } else {
      await _controller?.setFlashMode(FlashMode.torch);
    }
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void toggleStrobe() {
    setState(() {
      _isStrobeActive = !_isStrobeActive;
    });
    if (_isStrobeActive) {
      startStrobe();
    } else {
      stopStrobe();
    }
  }

  void startStrobe() {
    Future.delayed(Duration(milliseconds: _strobeInterval), () {
      if (_isStrobeActive) {
        toggleFlash();
        startStrobe();
      }
    });
  }

  void stopStrobe() {
    _controller?.setFlashMode(FlashMode.off);
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _imageOpacity = 0.5; // Reset opacity when a new image is picked
        _imageScale = 1.0; // Reset scale when a new image is picked
        _imagePosition = Offset(100, 100); // Reset position when a new image is picked
      });
    }
  }

  void showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                    onPressed: toggleFlash,
                  ),
                  IconButton(
                    icon: Icon(_isStrobeActive ? Icons.stop : Icons.flash_auto),
                    onPressed: toggleStrobe,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Slider for opacity adjustment
              SizedBox(
                width: 200,
                child: Slider(
                  value: _imageOpacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _imageOpacity = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Slider for scale adjustment
              SizedBox(
                width: 200,
                child: Slider(
                  value: _imageScale,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() {
                      _imageScale = value;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyDraw'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: showSettingsBottomSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!), // Full height camera preview
          if (_imageFile != null)
            Positioned(
              left: _imagePosition.dx,
              top: _imagePosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _imagePosition += details.delta; // Move the image
                  });
                },
                child: Transform.scale(
                  scale: _imageScale,
                  child: Opacity(
                    opacity: _imageOpacity,
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          if (_showGrid)
            Column(
              children: List.generate(
                10,
                    (index) => Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: List.generate(
                          10,
                              (index) => Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}