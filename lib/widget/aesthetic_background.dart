import 'package:flutter/material.dart';

/// Reusable aesthetic iOS ambient background layer with subtle medical-grade
/// light orbs and top gradient wash, creating soft depth behind content.
class AestheticBackground extends StatelessWidget {
  final Widget child;
  final bool hasTopWash;

  const AestheticBackground({
    super.key,
    required this.child,
    this.hasTopWash = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid iOS system grouped background
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFFF2F2F7)),
        ),

        // Ambient top gradient wash
        if (hasTopWash)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFCCFBF1).withValues(alpha: 0.35),
                    const Color(0xFFE0F2FE).withValues(alpha: 0.15),
                    const Color(0xFFF2F2F7).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // Ambient Teal Light Orb (Top Right)
        Positioned(
          top: -70,
          right: -60,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F766E).withValues(alpha: 0.08),
                    const Color(0xFF14B8A6).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Ambient Azure Light Orb (Mid Left)
        Positioned(
          top: 180,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.06),
                    const Color(0xFF38BDF8).withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Foreground Content
        child,
      ],
    );
  }
}
