import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
  // Electrode status: 'correct', 'noisy', 'error'
  String statusRA = 'correct';
  String statusLA = 'correct';
  String statusRL = 'correct';
  String statusLL = 'correct';

  final Map<String, Map<String, double>> electrodePositions = {
    'RA': {'x': 77.0488 / 240, 'y': 100.049 / 541},
    'LA': {'x': 164.049 / 240, 'y': 100.049 / 541},
    'RL': {'x': 81.0488 / 240, 'y': 243.049 / 541},
    'LL': {'x': 158.049 / 240, 'y': 242.049 / 541},
  };

  void _cycleElectrodeStatus(String electrode) {
    setState(() {
      switch (electrode) {
        case 'RA':
          statusRA = _getNextStatus(statusRA);
          break;
        case 'LA':
          statusLA = _getNextStatus(statusLA);
          break;
        case 'RL':
          statusRL = _getNextStatus(statusRL);
          break;
        case 'LL':
          statusLL = _getNextStatus(statusLL);
          break;
      }
    });
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'correct':
        return 'noisy';
      case 'noisy':
        return 'error';
      case 'error':
        return 'correct';
      default:
        return 'correct';
    }
  }

  String _getElectrodeStatus(String electrode) {
    switch (electrode) {
      case 'RA':
        return statusRA;
      case 'LA':
        return statusLA;
      case 'RL':
        return statusRL;
      case 'LL':
        return statusLL;
      default:
        return 'correct';
    }
  }

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
              child: Column(
                children: [
                  Text(
                    'ECG Electrode Placement & Status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap electrodes to cycle status: Correct → Noisy → Error',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // SVG Display with electrode overlays - Takes most of the screen
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 240 / 541, // Maintain exact SVG aspect ratio
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Background skeleton PNG
                            Positioned.fill(
                              child: Image.asset(
                                'assets/Lead6a.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey.shade600,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Lead6a.png not found',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Always show all electrodes
                            _buildElectrodeOverlay('RA', constraints),
                            _buildElectrodeOverlay('LA', constraints),
                            _buildElectrodeOverlay('RL', constraints),
                            _buildElectrodeOverlay('LL', constraints),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Status reset button at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      statusRA = 'correct';
                      statusLA = 'correct';
                      statusRL = 'correct';
                      statusLL = 'correct';
                    });
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Reset All Status to Correct'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectrodeOverlay(
    String electrodeName,
    BoxConstraints constraints,
  ) {
    final position = electrodePositions[electrodeName]!;
    final String status = _getElectrodeStatus(electrodeName);

    final double baseDimension =
        constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
    final double electrodeSize = baseDimension * 0.08;
    final double clampedElectrodeSize = electrodeSize.clamp(20.0, 60.0);

    return Positioned(
      left:
          (constraints.maxWidth * position['x']!) - (clampedElectrodeSize / 2),
      top:
          (constraints.maxHeight * position['y']!) - (clampedElectrodeSize / 2),
      child: GestureDetector(
        onTap: () => _cycleElectrodeStatus(electrodeName),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main electrode
            Container(
              width: clampedElectrodeSize,
              height: clampedElectrodeSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(clampedElectrodeSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
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

            // Status indicator
            if (status != 'correct')
              Positioned(
                right: -8,
                top: -8,
                child: _buildStatusIndicator(
                  status,
                  clampedElectrodeSize * 0.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, double size) {
    switch (status) {
      case 'noisy':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Lottie.asset(
            'assets/noisy.json', // You'll need to add this animation
            width: size * 0.8,
            height: size * 0.8,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.warning, color: Colors.white, size: size * 0.6);
            },
          ),
        );
      case 'error':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Lottie.asset(
            'assets/error.json', // You'll need to add this animation
            width: size * 0.8,
            height: size * 0.8,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.white, size: size * 0.6);
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
