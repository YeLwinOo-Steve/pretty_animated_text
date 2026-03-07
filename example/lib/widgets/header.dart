import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Header extends StatelessWidget {
  final ColorScheme colorScheme;
  const Header({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.text_fields_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              'Pretty Animated Text',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Row(
          children: [
            _SocialButton(
              url: 'https://pub.dev/packages/pretty_animated_text',
              assetPath: 'assets/pub.png',
              tooltip: 'Pub.dev',
            ),
            SizedBox(width: 12),
            _SocialButton(
              url: 'https://github.com/YeLwinOo-Steve/pretty_animated_text',
              assetPath: 'assets/github.png',
              tooltip: 'GitHub',
            ),
          ],
        )
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String url;
  final String assetPath;
  final String tooltip;

  const _SocialButton(
      {required this.url, required this.assetPath, required this.tooltip});

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: _launch,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5)),
          ),
          child: Image.asset(assetPath),
        ),
      ),
    );
  }
}
