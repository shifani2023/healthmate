import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String asset;
  final Widget child;

  const BackgroundImage({
    super.key,
    required this.asset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Theme.of(context).colorScheme.surface),
        ),
        // A light see-through layer so the text is easy to read
        Container(color: Colors.white.withValues(alpha: 0.7)),
        child,
      ],
    );
  }
}