import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RoadmapApp());
}

class RoadmapApp extends StatelessWidget {
  const RoadmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literary Roadmap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Arrancamos con el menú principal
    );
  }
}