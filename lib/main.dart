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

  // Electrode positions - these will need to be adjusted based on the actual SVG dimensions
  // Using relative positions (0.0 to 1.0) for better responsiveness
  final Map<String, Map<String, double>> electrodePositions = {
    'RA': {'x': 0.32, 'y': 0.185}, // Right Arm - left side on image
    'LA': {'x': 0.68, 'y': 0.185}, // Left Arm - right side on image
    'RL': {'x': 0.34, 'y': 0.45}, // Right Leg - left side on image
    'LL': {'x': 0.66, 'y': 0.45}, // Left Leg - right side on image
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Background skeleton SVG
                          Center(
                            child: SvgPicture.asset(
                              'assets/Lead6a.svg',
                              fit: BoxFit.contain,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                            ),
                          ),

                          // Electrode PNG overlays
                          if (showRA) _buildElectrodeOverlay('RA', constraints),
                          if (showLA) _buildElectrodeOverlay('LA', constraints),
                          if (showRL) _buildElectrodeOverlay('RL', constraints),
                          if (showLL) _buildElectrodeOverlay('LL', constraints),
                        ],
                      );
                    },
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

  // Helper to create electrode PNG overlays
  Widget _buildElectrodeOverlay(
    String electrodeName,
    BoxConstraints constraints,
  ) {
    final position = electrodePositions[electrodeName]!;
    const double electrodeSize = 40.0; // Size of the electrode PNG

    return Positioned(
      left: (constraints.maxWidth * position['x']!) - (electrodeSize / 2),
      top: (constraints.maxHeight * position['y']!) - (electrodeSize / 2),
      child: Container(
        width: electrodeSize,
        height: electrodeSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(electrodeSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(electrodeSize / 2),
          child: Image.asset('assets/$electrodeName.png', fit: BoxFit.contain),
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
