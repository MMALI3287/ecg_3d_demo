import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({Key? key}) : super(key: key);

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  WebViewController? webViewController;
  final String modelPath = "assets/Human_Body_3D.glb";
  bool isModelLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Model Viewer
          Container(
            color: Colors.grey.shade300,
            width: double.infinity,
            height: double.infinity,
            child: ModelViewer(
              src: modelPath,
              autoRotate: true,
              cameraControls: true,
              onWebViewCreated: (controller) {
                webViewController = controller;
                
                // Wait for the model to load
                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    isModelLoaded = true;
                  });
                });
              },
            ),
          ),
          
          // Loading indicator
          if (!isModelLoaded)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading 3D model...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          
          // Pen edit button
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.black87),
                  onPressed: () {
                    // This will be implemented later as per your requirements
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit functionality coming soon')),
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
