import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  // SVG key for reference
  final GlobalKey svgKey = GlobalKey();

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
                  child: Stack(
                    children: [
                      // Main SVG
                      SvgPicture.asset(
                        'assets/Lead6.svg',
                        key: svgKey,
                        fit: BoxFit.contain,
                      ),
                      
                      // Overlay circles for hiding electrodes
                      if (!showRA) _buildHidingCircle(77.0, 100.0),
                      if (!showLA) _buildHidingCircle(164.0, 100.0),
                      if (!showRL) _buildHidingCircle(81.0, 243.0),
                      if (!showLL) _buildHidingCircle(158.0, 242.0),
                    ],
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
  
  // Helper to create a white circle to hide electrodes
  Widget _buildHidingCircle(double x, double y) {
    return Positioned(
      left: x - 15, // Adjust based on SVG scale
      top: y - 15,  // Adjust based on SVG scale
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
      ),
    );
  }
}
