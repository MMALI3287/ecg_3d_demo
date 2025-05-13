import 'package:flutter/material.dart';
import 'model_viewer_screen.dart';
import 'layers_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Welcome to ECG 3D Demo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                const Text(
                  "Explore the human body model with ECG electrodes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // 3D Model Button
                _buildButton(
                  context,
                  "View 3D Model",
                  Icons.view_in_ar,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModelViewerScreen(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Layers Button
                _buildButton(
                  context,
                  "Electrode Layers",
                  Icons.layers,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LayersScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButton(
      BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return Container(
      width: 250,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6A11CB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
