import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(18),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Specialty Medical Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: meta.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  meta.icon,
                  color: meta.primaryColor,
                  size: 24,
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (isNumericId) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "#${poli.id}",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Category Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: meta.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meta.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: meta.primaryColor,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // iOS Table Disclosure Chevron
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
