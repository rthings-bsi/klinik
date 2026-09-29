import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';

/// Reusable Luxury / Editorial background with clean Warm Alabaster base.
class AestheticBackground extends StatelessWidget {
  final Widget child;
  final bool hasGridlines;

  const AestheticBackground({
    super.key,
    required this.child,
    this.hasGridlines = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LuxuryTheme.alabaster,
      child: child,
    );
  }
}
