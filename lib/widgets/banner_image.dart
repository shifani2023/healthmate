import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String asset;
  final double height;

  const BannerImage({
    super.key,
    required this.asset,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        asset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          height: height,
          child: const Center(child: Icon(Icons.image_not_supported)),
        ),
      ),
    );
  }
}