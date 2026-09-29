import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import 'animated_pressable.dart';

class NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class ElegantNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const ElegantNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.alabaster,
        border: Border(
          top: BorderSide(
            color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: AnimatedPressable(
                  borderRadius: BorderRadius.zero,
                  onTap: () => onTap(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Editorial Top Gold Active Indicator Bar
                      Positioned(
                        top: 0,
                        left: 24,
                        right: 24,
                        height: 2.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          curve: const Cubic(0.25, 0.46, 0.45, 0.94),
                          color: isSelected
                              ? LuxuryTheme.metallicGold
                              : Colors.transparent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 21,
                              color: isSelected
                                  ? LuxuryTheme.charcoal
                                  : LuxuryTheme.warmGrey,
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 320),
                              curve: const Cubic(0.25, 0.46, 0.45, 0.94),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? LuxuryTheme.charcoal
                                    : LuxuryTheme.warmGrey,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
