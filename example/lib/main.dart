import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
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
          seedColor: kBrandIndigo,
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const _GradientScaffold(),
    );
  }
}

class _GradientScaffold extends StatelessWidget {
  const _GradientScaffold();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kBgGradientTop,
                  kBgGradientBottom,
                  kBgGradientTop,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        const HomeWidget(),
      ],
    );
  }
}
