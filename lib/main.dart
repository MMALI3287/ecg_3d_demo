import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/welcome_screen.dart';

void main() {
  // Filter out annoying OpenGL logs
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && 
          !(message.contains('EGL_emulation') || 
            message.contains('libEGL') ||
            message.contains('OpenGL ES'))) {
        debugPrintSynchronously(message, wrapWidth: wrapWidth);
      }
    };
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG 3D Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
