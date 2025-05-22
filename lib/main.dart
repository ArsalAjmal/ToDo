import 'package:flutter/material.dart';
import 'screens/notes_screen.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // We only need to initialize SQLite for desktop platforms
  if (!kIsWeb) {
    try {
      // Check if we're on desktop
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Initialize SQLite for desktop with FFI
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        print('Initialized SQLite for desktop: ${Platform.operatingSystem}');
      } else {
        print('Using default SQLite for mobile: ${Platform.operatingSystem}');
      }
    } catch (e) {
      // This error happens on web because Platform is not available
      print('Platform detection error (probably web): $e');
    }
  } else {
    print('Running on web platform - using in-memory database');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        primaryColor: Color(0xFFC8F4F9),
        scaffoldBackgroundColor: Color(0xFFC8F4F9),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFC8F4F9),
          secondary: Color(0xFF3CACAE), // Teal color as secondary
          background: Color(0xFFC8F4F9),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFC8F4F9),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
