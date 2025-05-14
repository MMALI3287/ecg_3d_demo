import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 3D Model Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InteractiveModelViewPage(),
    );
  }
}

class InteractiveModelViewPage extends StatefulWidget {
  const InteractiveModelViewPage({Key? key}) : super(key: key);

  @override
  _InteractiveModelViewPageState createState() =>
      _InteractiveModelViewPageState();
}

class _InteractiveModelViewPageState extends State<InteractiveModelViewPage> {
  WebViewController? _controller;

  // Updated material names to match the 3D model
  final String electrodeNodeNameGreen = 'RBOk';
  final String electrodeNodeNameRed = 'RBMiss';
  final String electrodeNodeNameWhite = 'RBN';

  // Track visibility state
  bool isGreenVisible = true;
  bool isRedVisible = true;
  bool isWhiteVisible = true;
  @override
  void initState() {
    super.initState();
  }

  void materialNames() {
    if (_controller != null) {
      final jsScript = '''
        (async () => {
          const modelViewer = document.querySelector('model-viewer');
          
          await new Promise((resolve) => {
            if (modelViewer.loaded) {
              resolve();
            } else {
              modelViewer.addEventListener('load', () => resolve(), { once: true });
            }
          });

          console.log('Model loaded, checking materials...');
          const model = await modelViewer.model;

          if (model && model.materials) {
            console.log('Total materials found:', model.materials.length);
            console.log('--- Available Materials ---');
            model.materials.forEach(material => {
              console.log('Material name:', material.name);
              console.log('Material properties:', {
                baseColorFactor: material.pbrMetallicRoughness?.baseColorFactor,
                alphaMode: material.alphaMode
              });
            });
          } else {
            console.log('No materials found or model not loaded properly');
          }
          console.log('--------------------------');
        })();
      ''';
      _controller!.runJavaScript(jsScript);
    } else {
      print("WebViewController not ready yet.");
    }
  }

  void toggleNodeVisibility(String materialName, bool isVisible) {
    if (_controller != null) {
      final jsScript = '''
        (async () => {
          const modelViewer = document.querySelector('model-viewer');
          await modelViewer.model;

          materialNames();
          
          const material = modelViewer.model.materials.find(m => m.name === '$materialName');
          if (material) {
            material.pbrMetallicRoughness.setBaseColorFactor([
              material.pbrMetallicRoughness.baseColorFactor[0],
              material.pbrMetallicRoughness.baseColorFactor[1],
              material.pbrMetallicRoughness.baseColorFactor[2],
              $isVisible ? 1.0 : 0.0
            ]);
            material.alphaMode = 'BLEND';
            console.log('Material "$materialName" visibility set to $isVisible');
          } else {
            console.warn('Material "$materialName" not found in the model.');
          }
        })();
      ''';
      _controller!.runJavaScript(jsScript);
    } else {
      print("WebViewController not ready yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive 3D Human Body Model')),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
              src: 'assets/Human_Body_3D.glb',
              alt: 'A 3D model of a human body with electrodes',
              autoRotate: true,
              cameraControls: true,
              onWebViewCreated: (controller) {
                setState(() {
                  _controller = controller;
                  print("WebViewController created.");
                });
                // Call materialNames after a short delay to ensure everything is initialized
                Future.delayed(const Duration(milliseconds: 500), () {
                  materialNames();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isGreenVisible = false);
                                toggleNodeVisibility(
                                  electrodeNodeNameGreen,
                                  false,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isGreenVisible ? Colors.green : Colors.grey,
                      ),
                      child: const Text('Hide Green'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isGreenVisible = true);
                                toggleNodeVisibility(
                                  electrodeNodeNameGreen,
                                  true,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isGreenVisible ? Colors.green : Colors.grey,
                      ),
                      child: const Text('Show Green'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isRedVisible = false);
                                toggleNodeVisibility(
                                  electrodeNodeNameRed,
                                  false,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isRedVisible ? Colors.red : Colors.grey,
                      ),
                      child: const Text('Hide Red'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isRedVisible = true);
                                toggleNodeVisibility(
                                  electrodeNodeNameRed,
                                  true,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isRedVisible ? Colors.red : Colors.grey,
                      ),
                      child: const Text('Show Red'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isWhiteVisible = false);
                                toggleNodeVisibility(
                                  electrodeNodeNameWhite,
                                  false,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isWhiteVisible ? Colors.white : Colors.grey,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Hide White'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _controller != null
                              ? () {
                                setState(() => isWhiteVisible = true);
                                toggleNodeVisibility(
                                  electrodeNodeNameWhite,
                                  true,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isWhiteVisible ? Colors.white : Colors.grey,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Show White'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
