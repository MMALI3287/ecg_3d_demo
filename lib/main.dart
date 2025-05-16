import 'dart:convert';
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
  const InteractiveModelViewPage({Key? key}) : super(key: key);
  @override
  _InteractiveModelViewPageState createState() =>
      _InteractiveModelViewPageState();
}

class _InteractiveModelViewPageState extends State<InteractiveModelViewPage> {
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

  void _setupConsole() {
    if (_controller == null) return;
    _controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Console',
        onMessageReceived: (m) {
          print('WebView Console: ${m.message}');
        },
      )
      ..runJavaScript(r'''
        (function() {
          function serialize(args) {
            try { return JSON.stringify(Array.from(args)); }
            catch { return Array.from(args).map(String).join(' '); }
          }
          ['log','warn','error'].forEach(level=>{
            const orig=console[level];
            console[level]=function(){
              Console.postMessage(level.toUpperCase()+': '+serialize(arguments));
              orig.apply(console,arguments);
            };
          });
          window.onerror=(msg,src,ln)=> {
            Console.postMessage('ERROR: '+msg+' at '+src+':'+ln);
            return false;
          };
        })();
      ''');
  }

  void listHierarchy() {
    if (_controller == null) return;
    _controller!.runJavaScript(r'''
(async()=> {
  const mv=document.querySelector('model-viewer');
  if(!mv) return console.error('No <model-viewer>');
  await new Promise(r=>mv.loaded?r():mv.addEventListener('load',r,{once:true}));
  console.log('--- Hierarchy names ---');
  const model=await mv.model;
  // pick the internal "hierarchy" symbol
  const sym=Object.getOwnPropertySymbols(model)
    .find(s=>s.description==='hierarchy');
  if(!sym) {
    console.error('No hierarchy symbol');
    return console.dir(model);
  }
  model[sym].forEach(o=> console.log(' •', o.name));
  console.log('--- end ---');
})();''');
  }

  void toggleNode(String nodeName, bool visible) {
    if (_controller == null) return;
    final nJs = json.encode(nodeName);
    final vJs = visible.toString();
    _controller!.runJavaScript('''
(async()=> {
  const mv=document.querySelector('model-viewer');
  if(!mv) return console.error('No <model-viewer>');
  await new Promise(r=>mv.loaded?r():mv.addEventListener('load',r,{once:true}));
  const model=await mv.model;
  // find the symbol-based hierarchy array
  const sym=Object.getOwnPropertySymbols(model)
    .find(s=>s.description==='hierarchy');
  if(!sym) return console.error('No hierarchy symbol');
  const node=model[sym].find(o=>o.name===$nJs);
  if(!node) return console.error('Node not found:', $nJs);
  if(!node.materials|| !(node.materials instanceof Map)) {
    console.error('No materials map on node:', $nJs);
    return console.dir(node);
  }
  node.materials.forEach(mat=>{
    if(mat.pbrMetallicRoughness) {
      const c=mat.pbrMetallicRoughness.baseColorFactor;
      mat.pbrMetallicRoughness.setBaseColorFactor([c[0],c[1],c[2], $vJs?1:0]);
      mat.alphaMode='BLEND';
    }
  });
  console.log('Toggled materials alpha for', $nJs, '=>', $vJs);
})();''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 3D Model Viewer')),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: 'assets/Human_Body_3D.glb',
              alt: '3D body',
              autoRotate: true,
              cameraControls: true,
              loading: Loading.eager,
              onWebViewCreated: (c) {
                _controller = c;
                print('WebViewController created');
                _setupConsole();
                Future.delayed(
                  const Duration(milliseconds: 1000),
                  listHierarchy,
                );
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
                        toggleNode(electrodeNodeGreen, false);
                      },
                      child: const Text('Hide Green'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isGreenVisible = true);
                        toggleNode(electrodeNodeGreen, true);
                      },
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
                        toggleNode(electrodeNodeRed, false);
                      },
                      child: const Text('Hide Red'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isRedVisible = true);
                        toggleNode(electrodeNodeRed, true);
                      },
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
                        toggleNode(electrodeNodeWhite, false);
                      },
                      child: const Text('Hide White'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isWhiteVisible = true);
                        toggleNode(electrodeNodeWhite, true);
                      },
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
}
