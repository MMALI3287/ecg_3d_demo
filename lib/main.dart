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

  // Electrode positions based on the actual SVG coordinate system
  // SVG viewBox is "0 0 240 541" - converting to relative positions
  final Map<String, Map<String, double>> electrodePositions = {
    'RA': {
      'x': 77.0488 / 240,
      'y': 100.049 / 541,
    }, // Exact coordinates from SVG
    'LA': {
      'x': 164.049 / 240,
      'y': 100.049 / 541,
    }, // Exact coordinates from SVG
    'RL': {
      'x': 81.0488 / 240,
      'y': 243.049 / 541,
    }, // Exact coordinates from SVG
    'LL': {
      'x': 158.049 / 240,
      'y': 242.049 / 541,
    }, // Exact coordinates from SVG
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

            // SVG Display with electrode overlays
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 240 / 541, // Maintain SVG aspect ratio exactly
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Background skeleton SVG - positioned to fill the exact aspect ratio
                            Positioned.fill(
                              child: SvgPicture.asset(
                                'assets/Lead6a.svg',
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Electrode PNG overlays with precise positioning
                            if (showRA)
                              _buildElectrodeOverlay('RA', constraints),
                            if (showLA)
                              _buildElectrodeOverlay('LA', constraints),
                            if (showRL)
                              _buildElectrodeOverlay('RL', constraints),
                            if (showLL)
                              _buildElectrodeOverlay('LL', constraints),
                          ],
                        );
                      },
                    ),
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
                    // Electrode toggle buttons in a grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          _buildElectrodeToggle(
                            'RA',
                            Colors.red.shade700,
                            showRA,
                            (value) => setState(() => showRA = value),
                          ),
                          _buildElectrodeToggle(
                            'LA',
                            Colors.purple.shade700,
                            showLA,
                            (value) => setState(() => showLA = value),
                          ),
                          _buildElectrodeToggle(
                            'RL',
                            Colors.amber.shade700,
                            showRL,
                            (value) => setState(() => showRL = value),
                          ),
                          _buildElectrodeToggle(
                            'LL',
                            Colors.green.shade700,
                            showLL,
                            (value) => setState(() => showLL = value),
                          ),
                        ],
                      ),
                    ),

                    // Reset all button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showRA = true;
                                showLA = true;
                                showRL = true;
                                showLL = true;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Show All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showRA = false;
                                showLA = false;
                                showRL = false;
                                showLL = false;
                              });
                            },
                            icon: const Icon(Icons.visibility_off),
                            label: const Text('Hide All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  // Helper to create electrode PNG overlays with precise positioning
  Widget _buildElectrodeOverlay(
    String electrodeName,
    BoxConstraints constraints,
  ) {
    final position = electrodePositions[electrodeName]!;

    // Calculate electrode size based on screen size but keep it proportional
    // Use the smaller dimension to ensure consistency across all screen sizes
    final double baseDimension =
        constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
    final double electrodeSize =
        baseDimension * 0.08; // 8% of the smaller dimension

    // Ensure minimum and maximum sizes for usability
    final double clampedElectrodeSize = electrodeSize.clamp(20.0, 60.0);

    return Positioned(
      left:
          (constraints.maxWidth * position['x']!) - (clampedElectrodeSize / 2),
      top:
          (constraints.maxHeight * position['y']!) - (clampedElectrodeSize / 2),
      child: Container(
        width: clampedElectrodeSize,
        height: clampedElectrodeSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(clampedElectrodeSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(clampedElectrodeSize / 2),
          child: Image.asset(
            'assets/$electrodeName.png',
            fit: BoxFit.contain,
            width: clampedElectrodeSize,
            height: clampedElectrodeSize,
          ),
        ),
      ),
    );
  }

  // Helper to create electrode toggle buttons
  Widget _buildElectrodeToggle(
    String name,
    Color color,
    bool isVisible,
    Function(bool) onChanged,
  ) {
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          Switch(value: isVisible, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }
}
