import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/poli_helper.dart';
import '../model/poli.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import 'poli_detail.dart';

class PoliItem extends StatelessWidget {
  final Poli poli;
  final VoidCallback? onRefresh;

  const PoliItem({super.key, required this.poli, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final meta = PoliHelper.getMeta(poli.namaPoli);
    final isNumericId = poli.id != null && RegExp(r'^\d+$').hasMatch(poli.id!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(page: PoliDetail(poli: poli)),
          );
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Specialty Medical Icon Container with rounded corners
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  meta.icon,
                  color: LuxuryTheme.charcoal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Categorical Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            poli.namaPoli,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: LuxuryTheme.charcoal,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isNumericId) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "#${poli.id}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: LuxuryTheme.charcoal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meta.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: LuxuryTheme.warmGrey,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Disclosure Chevron
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: LuxuryTheme.charcoal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
