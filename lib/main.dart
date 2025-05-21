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

  void _setupConsoleListener() {
    if (_controller == null) return;
    _controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Console',
        onMessageReceived: (msg) {
          print('WebView ▶ ${msg.message}');
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
  const mv=document.querySelector('model-viewer');
  if(!mv) return console.error('No <model-viewer>');
  await new Promise(r=>mv.loaded?r():mv.addEventListener('load',r,{once:true}));
  const model=await mv.model;
  const sym=Object.getOwnPropertySymbols(model)
                .find(s=>s.description==='hierarchy');
  if(!sym) return console.error('No hierarchy symbol');
  console.log('--- Hierarchy names ---');
  model[sym].forEach(o=>console.log(' •',o.name));
  console.log('--- end ---');
})();
''');
  }

  void toggleNodeVisibility(String nodeName, bool isVisible) {
    if (_controller == null) return;
    final jsName = json.encode(nodeName);
    final jsVis = isVisible.toString();
    final js = """
(async()=>{
  const mv = document.querySelector('model-viewer');
  if (!mv) return console.error('No <model-viewer>');
  await new Promise(r=> mv.loaded ? r() : mv.addEventListener('load', r, {once:true}));

  const model = await mv.model;
  const sym = Object.getOwnPropertySymbols(model)
                  .find(s => s.description==='hierarchy');
  if (!sym) return console.error('No hierarchy symbol');
  const node = model[sym].find(o => o.name===${jsName});
  if (!node) return console.error('Node not found:', ${jsName});

  if (!node.mesh) {
    console.error('No .mesh on node:', ${jsName});
    return console.dir(node);
  }

  // Capture original parent once
  if (!node._origParent && node.mesh.parent) {
    node._origParent = node.mesh.parent;
  }
  const parent = node._origParent;
  if (!parent) {
    console.error('Original parent lost for node:', ${jsName});
    return;
  }

  if (${jsVis}) {
    parent.add(node.mesh);
    console.log('MESH SHOWN for', ${jsName});
  } else {
    parent.remove(node.mesh);
    console.log('MESH HIDDEN for', ${jsName});
  }
})();
""";
    _controller!.runJavaScript(js).catchError((e) {
      print('Flutter: JS toggle error: $e');
    });
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
              onWebViewCreated: (ctrl) {
                _controller = ctrl;
                print('▶ WebViewController created');
                _setupConsoleListener();
                Future.delayed(const Duration(seconds: 1), listHierarchy);
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
                      child: const Text('Hide Green'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isGreenVisible = true);
                        toggleNodeVisibility(electrodeNodeGreen, true);
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
                        toggleNodeVisibility(electrodeNodeRed, false);
                      },
                      child: const Text('Hide Red'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isRedVisible = true);
                        toggleNodeVisibility(electrodeNodeRed, true);
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
                        toggleNodeVisibility(electrodeNodeWhite, false);
                      },
                      child: const Text('Hide White'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isWhiteVisible = true);
                        toggleNodeVisibility(electrodeNodeWhite, true);
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
