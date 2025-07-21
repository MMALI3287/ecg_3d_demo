import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG Electrodes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ECGElectrodesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ECGElectrodesPage extends StatefulWidget {
  const ECGElectrodesPage({super.key});

  @override
  State<ECGElectrodesPage> createState() => _ECGElectrodesPageState();
}

class _ECGElectrodesPageState extends State<ECGElectrodesPage> {
  // Visibility flags for electrodes
  bool showRA = true;
  bool showLA = true;
  bool showRL = true;
  bool showLL = true;

  // SVG data
  String? svgData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      // Load the SVG file as a string
      final String data = await rootBundle.loadString('assets/Lead6.svg');
      setState(() {
        svgData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading SVG: $e');
    }
  }

  String _getModifiedSvgData() {
    if (svgData == null) return '';
    
    String modifiedSvg = svgData!;
    
    // The IDs for our electrodes - these are based on examining the SVG content
    final Map<String, Map<String, dynamic>> electrodes = {
      'RA': {
        'visible': showRA,
        'circleId': 'circle cx="77.0488" cy="100.049"',
        'textId': 'path d="M70.6562 104.604V96.568H73.3713'
      },
      'LA': {
        'visible': showLA,
        'circleId': 'circle cx="164.049" cy="100.049"',
        'textId': 'path d="M157.656 104.604V96.568H158.629'
      },
      'RL': {
        'visible': showRL,
        'circleId': 'circle cx="81.0488" cy="243.049"',
        'textId': 'path d="M75.5766 247.604V239.568H78.2917'
      },
      'LL': {
        'visible': showLL,
        'circleId': 'circle cx="158.049" cy="242.049"',
        'textId': 'path d="M153.498 246.604V238.568H154.471'
      },
    };

    // Modify each electrode based on visibility
    electrodes.forEach((key, electrode) {
      if (!electrode['visible']) {
        // Find the circle and replace it with an empty/transparent circle
        // We keep the position attributes but change the fill to "none" and opacity to 0
        final String circlePattern = electrode['circleId'];
        final int circleStart = modifiedSvg.indexOf(circlePattern);
        
        if (circleStart != -1) {
          // Find the end of the circle tag
          final int circleEnd = modifiedSvg.indexOf('>', circleStart);
          if (circleEnd != -1) {
            final String originalCircle = modifiedSvg.substring(circleStart, circleEnd);
            // Create a new circle with opacity 0
            final String newCircle = '$originalCircle fill="none" opacity="0"';
            modifiedSvg = modifiedSvg.replaceRange(circleStart, circleEnd, newCircle);
          }
        }
        
        // Hide the label text by setting its opacity to 0
        final String textPattern = electrode['textId'];
        final int textStart = modifiedSvg.indexOf(textPattern);
        
        if (textStart != -1) {
          // Add opacity attribute to the path
          final int textEnd = modifiedSvg.indexOf('>', textStart);
          if (textEnd != -1) {
            final String originalText = modifiedSvg.substring(textStart, textEnd);
            final String newText = '$originalText opacity="0"';
            modifiedSvg = modifiedSvg.replaceRange(textStart, textEnd, newText);
          }
        }
      }
    });

    return modifiedSvg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No AppBar as requested
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ECG Electrode Placement',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            
            // SVG Display - Expanded to fill available space
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLoading
                    ? const CircularProgressIndicator()
                    : svgData == null
                        ? const Text('Failed to load SVG')
                        : SvgPicture.string(
                            _getModifiedSvgData(),
                            fit: BoxFit.contain,
                          ),
                ),
              ),
            ),
            
            // Controls
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Toggle Electrodes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    
                    // Electrode toggle buttons in a grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _buildElectrodeToggle('RA', Colors.red.shade700, showRA, 
                            (value) => setState(() => showRA = value)),
                          _buildElectrodeToggle('LA', Colors.purple.shade700, showLA, 
                            (value) => setState(() => showLA = value)),
                          _buildElectrodeToggle('RL', Colors.amber.shade700, showRL, 
                            (value) => setState(() => showRL = value)),
                          _buildElectrodeToggle('LL', Colors.green.shade700, showLL, 
                            (value) => setState(() => showLL = value)),
                        ],
                      ),
                    ),
                    
                    // Bottom note
                    Text(
                      'Standard 12-Lead ECG Placement',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper to create electrode toggle buttons
  Widget _buildElectrodeToggle(String name, Color color, bool isVisible, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isVisible ? color.withOpacity(0.2) : Colors.grey.shade200,
        border: Border.all(
          color: isVisible ? color : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Electrode name and colored circle
          Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isVisible ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          // Switch
          Switch(
            value: isVisible,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}
