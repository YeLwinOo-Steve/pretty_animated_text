import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Demo Content
const demoText = 'Bring motion to your text. Keep your UI elegant!';

final demoTextStyle = GoogleFonts.plusJakartaSans(
  fontSize: 52,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF1E293B),
  height: 1.2,
  letterSpacing: -0.5,
);

const letterAnimationDuration = Duration(milliseconds: 300);
const wordAnimationDuration = Duration(milliseconds: 600);

// Primary Color
const kBrandIndigo = Color(0xFF6366F1);

// Background Gradient
const kBgGradientTop = Color(0xFFEEF0FF);
const kBgGradientBottom = Color(0xFFF8FAFC);

// Demo Canvas Gradient
const kCanvasGradientA = Color(0xFFF0F1FF);
const kCanvasGradientB = Color(0xFFFAFAFF);

// Status chip - semantic colors 
const kStatusPlaying = Color(0xFF10B981);
const kStatusPaused = Color(0xFFF59E0B);
const kStatusComplete = Color(0xFF6366F1);
const kStatusStopped = Color(0xFF94A3B8);

const kStatusPlayingBg = Color(0xFFD1FAE5);
const kStatusPausedBg = Color(0xFFFEF3C7);
const kStatusCompleteBg = Color(0xFFEEF0FF);
const kStatusStoppedBg = Color(0xFFF1F5F9);

// Shadows
const kCardShadows = [
  BoxShadow(
    color: Color(0x0F6366F1),
    blurRadius: 40,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 12,
    offset: Offset(0, 2),
  ),
];

const kNavSelectedShadows = [
  BoxShadow(
    color: Color(0x266366F1),
    blurRadius: 12,
    offset: Offset(0, 2),
  ),
];

const kControlPillShadows = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];

const kPlayButtonShadows = [
  BoxShadow(
    color: Color(0x596366F1),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];

const kPlayButtonPressedShadows = [
  BoxShadow(
    color: Color(0x336366F1),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

// Navigation icons
const kDemoIcons = <String, IconData>{
  'Scale': Icons.zoom_in_map_rounded,
  'Slide': Icons.swap_horiz_rounded,
  'Rotate': Icons.rotate_right_rounded,
  'Chime Bell': Icons.notifications_rounded,
  'Spring': Icons.directions_run_rounded,
  'Blur': Icons.blur_on_rounded,
};
