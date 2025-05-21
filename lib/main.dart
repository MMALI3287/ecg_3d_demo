import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter 3D Model Viewer',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const InteractiveModelViewPage(),
  );
}

class InteractiveModelViewPage extends StatefulWidget {
  const InteractiveModelViewPage({super.key});
  @override
  InteractiveModelViewPageState createState() =>
      InteractiveModelViewPageState();
}

class InteractiveModelViewPageState extends State<InteractiveModelViewPage> {
  WebViewController? _controller;

  final String electrodeNodeGreen = 'Electrods_Original_Green';
  final String electrodeNodeRed = 'Electrods_Original_Red';
  final String electrodeNodeWhite = 'Electrods_Original_White';

  bool isGreenVisible = true;
  bool isRedVisible = true;
  bool isWhiteVisible = true;

  @override
  void initState() {
    super.initState();
  }

  void _setupConsoleListener() {
    if (_controller == null) return;
    _controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Console',
        onMessageReceived: (msg) {
          if (kDebugMode) {
            print('WebView ▶ ${msg.message}');
          }
        },
      )
      ..runJavaScript(r'''
(function(){
  function serialize(a){ try{return JSON.stringify(Array.from(a));}catch{return Array.from(a).join(' ');} }
  ['log','warn','error'].forEach(l=>{
    const o=console[l];
    console[l]=function(){
      Console.postMessage(l.toUpperCase()+': '+serialize(arguments));
      o.apply(console,arguments);
    }
  });
  window.onerror=(m,s,l,n)=> Console.postMessage('ERROR: '+m+' @'+s+':'+l);
})();
''');
  }

  void listHierarchy() {
    if (_controller == null) return;
    _controller!.runJavaScript(r'''
(async()=>{
  const mv = document.querySelector('model-viewer');
  if(!mv) return console.error('No <model-viewer>');
  
  try {
    // Make sure model is loaded first
    if(!mv.loaded) {
      console.log('Model not loaded yet, waiting...');
      await new Promise(r => mv.addEventListener('load', r, {once:true}));
    }
    
    // Check all the object's properties
    console.log('--- Hierarchy names ---');
    
    // Look for symbols
    for(const sym of Object.getOwnPropertySymbols(mv.model)) {
      console.log(`Symbol: ${sym.toString()}`);
      try {
        const val = mv.model[sym];
        if(Array.isArray(val)) {
          console.log(`Found array with ${val.length} items at symbol`);
          val.forEach((item, i) => {
            if(item && item.name) console.log(' •', item.name);
          });
        }
      } catch(e) {}
    }
    
    console.log('--- end ---');
  } catch (error) {
    console.error('Error listing hierarchy:', error.toString());
  }
})();
''');
  }

  void toggleNodeVisibility(String nodeName, bool isVisible) {
    if (_controller == null) return;
    final jsName = json.encode(nodeName);
    final jsVis = isVisible.toString();

    final js = """
(async () => {
  const modelViewer = document.querySelector('model-viewer');
  if (!modelViewer) return console.error('No model-viewer found');
  
  try {
    // Wait for the model to be fully loaded
    if(!modelViewer.loaded) {
      console.log('Waiting for model to load...');
      await new Promise(resolve => modelViewer.addEventListener('load', resolve, {once: true}));
    }
    
    if (!modelViewer.model) {
      console.error('Model not available');
      return;
    }
    
    let success = false;
    
    // Method 1: Try to directly manipulate the primitive mesh at the "primitives" symbol
    try {
      const primitivesSymbol = Object.getOwnPropertySymbols(modelViewer.model)
        .find(sym => sym.toString().includes('primitives'));
      
      if (primitivesSymbol) {
        const primitives = modelViewer.model[primitivesSymbol];
        if (Array.isArray(primitives)) {
          const targetPrimitive = primitives.find(p => p && p.name === $jsName);
          if (targetPrimitive) {
            if (targetPrimitive.visible !== undefined) {
              targetPrimitive.visible = $jsVis;

              // Force a render update
              if (modelViewer.needsRender !== undefined) {
                modelViewer.needsRender = true;
              }

              console.log(`Set primitive visibility directly: \${$jsName} = \${$jsVis}`);
              success = true;
            }
            
            // Try to modify material properties as well
            if (targetPrimitive.material) {
              targetPrimitive.material.visible = $jsVis;
              targetPrimitive.material.transparent = !$jsVis;
              targetPrimitive.material.opacity = $jsVis ? 1.0 : 0.0;
              console.log(`Modified material properties for: \${$jsName}`);
              success = true;
            }
          }
        }
      }
    } catch(e) {
      console.log('Primitives method failed:', e.toString());
    }
    
    // Method 2: Try to find and modify all objects with the target name using scene traversal
    try {
      if (!success && modelViewer.model.traverse) {
        modelViewer.model.traverse((object) => {
          if (object.name === $jsName || object.name.includes($jsName)) {
            // Apply to the object itself
            if (object.visible !== undefined) {
              object.visible = $jsVis;
            }
            
            // Apply to all child objects
            if (object.children && object.children.length > 0) {
              object.children.forEach(child => {
                if (child.visible !== undefined) {
                  child.visible = $jsVis;
                }
                if (child.material) {
                  child.material.visible = $jsVis;
                  child.material.transparent = !$jsVis;
                  child.material.opacity = $jsVis ? 1.0 : 0.0;
                  child.material.needsUpdate = true;
                }
              });
            }
            
            // Apply to object's material if it exists
            if (object.material) {
              object.material.visible = $jsVis;
              object.material.transparent = !$jsVis;
              object.material.opacity = $jsVis ? 1.0 : 0.0;
              object.material.needsUpdate = true;
            }
            
            success = true;
            console.log(`Modified object via traverse: \${$jsName}`);
          }
        });
      }
    } catch(e) {
      console.log('Traverse method failed:', e.toString());
    }
    
    // Method 3: Directly manipulate hierarchy nodes
    try {
      if (!success) {
        const hierarchySymbol = Object.getOwnPropertySymbols(modelViewer.model)
          .find(sym => sym.toString().includes('hierarchy'));
        
        if (hierarchySymbol) {
          const hierarchyNodes = modelViewer.model[hierarchySymbol];
          if (Array.isArray(hierarchyNodes)) {
            const targetNode = hierarchyNodes.find(n => n && n.name === $jsName);
            if (targetNode) {
              // Try multiple property paths
              if (targetNode.mesh) {
                targetNode.mesh.visible = $jsVis;

                // Scale to zero as a backup method
                if (!$jsVis) {
                  targetNode.mesh.scale.set(0.00001, 0.00001, 0.00001);
                } else {
                  targetNode.mesh.scale.set(1, 1, 1);
                }
                
                if (targetNode.mesh.material) {
                  targetNode.mesh.material.visible = $jsVis;
                  targetNode.mesh.material.transparent = !$jsVis;
                  targetNode.mesh.material.opacity = $jsVis ? 1.0 : 0.0;
                  targetNode.mesh.material.needsUpdate = true;
                }

                console.log(`Modified hierarchy node mesh: \${$jsName}`);
                success = true;
              }
              
              // Try with the children
              if (targetNode.children && targetNode.children.length > 0) {
                targetNode.children.forEach(child => {
                  if (child.visible !== undefined) {
                    child.visible = $jsVis;
                  }
                  if (child.scale) {
                    if (!$jsVis) {
                      child.scale.set(0.00001, 0.00001, 0.00001);
                    } else {
                      child.scale.set(1, 1, 1);
                    }
                  }
                });
                console.log(`Modified hierarchy node children: \${$jsName}`);
                success = true;
              }
            }
          }
        }
      }
    } catch(e) {
      console.log('Hierarchy method failed:', e.toString());
    }
    
    // Force a render update
    if (success) {
      if (modelViewer.updateComplete) {
        await modelViewer.updateComplete;
      }
      if (typeof modelViewer.requestUpdate === 'function') {
        modelViewer.requestUpdate();
      }
      console.log(`Requested model update for: \${$jsName}`);
    } else {
      console.error(`Failed to modify visibility for: \${$jsName}`);
    }
  } catch (error) {
    console.error('Error toggling visibility:', error.toString());
  }
})();
""";

    _controller!.runJavaScript(js).catchError((e) {
      if (kDebugMode) {
        print('Flutter: JS toggle error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Model Viewer')),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: 'assets/Human_Body_3D.glb',
              alt: '3D body',
              ar: false,
              autoRotate: true,
              cameraControls: true,
              loading: Loading.eager,
              backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
              relatedJs: r'''
              // Wait for model to load, then initialize
              const modelViewer = document.querySelector('model-viewer');
              modelViewer.addEventListener('load', () => {
                console.log('Model loaded from HTML directly');
                // Ensure model is fully loaded
                setTimeout(() => {
                  if (!window.modelInitialized) {
                    window.modelInitialized = true;
                    // Force a render refresh
                    modelViewer.dismissPoster();
                    if (modelViewer.needsRender !== undefined) {
                      modelViewer.needsRender = true;
                    }
                  }
                }, 1000);
              });
              ''',
              onWebViewCreated: (ctrl) {
                _controller = ctrl;
                if (kDebugMode) {
                  print('▶ WebViewController created');
                }
                _setupConsoleListener();
                // Add delay to ensure model is loaded first
                Future.delayed(const Duration(seconds: 3), () {
                  listHierarchy();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isGreenVisible = false);
                        toggleNodeVisibility(electrodeNodeGreen, false);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isGreenVisible ? Colors.green : Colors.grey,
                        ),
                      ),
                      child: const Text('Hide Green'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isGreenVisible = true);
                        toggleNodeVisibility(electrodeNodeGreen, true);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isGreenVisible ? Colors.green : Colors.grey,
                        ),
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
                      onPressed: () {
                        setState(() => isRedVisible = false);
                        toggleNodeVisibility(electrodeNodeRed, false);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isRedVisible ? Colors.red : Colors.grey,
                        ),
                      ),
                      child: const Text('Hide Red'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isRedVisible = true);
                        toggleNodeVisibility(electrodeNodeRed, true);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isRedVisible ? Colors.red : Colors.grey,
                        ),
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
                      onPressed: () {
                        setState(() => isWhiteVisible = false);
                        toggleNodeVisibility(electrodeNodeWhite, false);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isWhiteVisible ? Colors.blue : Colors.grey,
                        ),
                      ),
                      child: const Text('Hide White'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isWhiteVisible = true);
                        toggleNodeVisibility(electrodeNodeWhite, true);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isWhiteVisible ? Colors.blue : Colors.grey,
                        ),
                      ),
                      child: const Text('Show White'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_controller == null) return;
                    _controller!.runJavaScript(r'''
                    // Force complete model refresh
                    const modelViewer = document.querySelector('model-viewer');
                    if (modelViewer) {
                      if (modelViewer.model) {
                        // Manually trigger a full scene graph update
                        modelViewer.model.traverse(obj => {
                          if (obj.material) obj.material.needsUpdate = true;
                        });
                      }
                      // Force a render
                      if (typeof modelViewer.requestUpdate === 'function') {
                        modelViewer.requestUpdate();
                      }
                      console.log('Forced model refresh');
                    }
                    ''');
                  },
                  child: const Text('Force Refresh Model'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
