import 'package:flutter/material.dart';
// import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                color: Colors.grey,
                width: double.infinity,
                child: ModelViewer(
                  src: "https://modelviewer.dev/shared-assets/models/Astronaut.glb", // Changed to remote URL
                  autoRotate: true,

                  // scale: 10,
                  //cameraY: 3,
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      //print("Animation => $a");
                    },
                    child: Text("Get available animation"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      //print("Textures => $a");
                    },
                    child: Text("Get available textures"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
