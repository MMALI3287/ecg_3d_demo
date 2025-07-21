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
  bool showRA = true;
  bool showLA = true;
  bool showRL = true;
  bool showLL = true;

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
                    aspectRatio: 240 / 541,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/Lead6a.png',
                                fit: BoxFit.contain,
                              ),
                            ),

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
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double screenWidth =
                              MediaQuery.of(context).size.width;
                          final double aspectRatio =
                              screenWidth > 600 ? 4.0 : 2.5;

                          return GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: aspectRatio,
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
                          );
                        },
                      ),
                    ),

                    // Control buttons
                    Column(
                      children: [
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
                        const SizedBox(height: 8),
                        SizedBox(
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

  Widget _buildElectrodeToggle(
    String name,
    Color color,
    bool isVisible,
    Function(bool) onChanged,
  ) {
    final String status = _getElectrodeStatus(name);
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    switch (status) {
      case 'noisy':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isVisible ? color.withValues(alpha: 0.2) : Colors.grey.shade200,
        border: Border.all(
          color: isVisible ? color : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Main toggle row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isVisible ? color : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                Switch(
                  value: isVisible,
                  onChanged: onChanged,
                  activeColor: color,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // Status change button
          Container(
            width: double.infinity,
            height: 24,
            child: TextButton(
              onPressed: () => _cycleElectrodeStatus(name),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Change Status',
                style: TextStyle(
                  fontSize: 8,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
