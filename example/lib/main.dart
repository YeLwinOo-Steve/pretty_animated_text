import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const PrettyAnimatedTextApp());
}

class PrettyAnimatedTextApp extends StatelessWidget {
  const PrettyAnimatedTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pretty Animated Text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          surface: const Color(0xFFF8FAFC), // Slate 50
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const HomeWidget(),
    );
  }
}
