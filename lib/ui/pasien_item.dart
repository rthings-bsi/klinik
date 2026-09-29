import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/pasien.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import 'pasien_detail.dart';

class PasienItem extends StatelessWidget {
  final Pasien pasien;
  final VoidCallback? onRefresh;

  const PasienItem({super.key, required this.pasien, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(page: PasienDetail(pasien: pasien)),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: LuxuryTheme.charcoal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pasien.nama,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: LuxuryTheme.charcoal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            "RM: ${pasien.nomorRm}",
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: LuxuryTheme.charcoal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pasien.nomorTelepon,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: LuxuryTheme.warmGrey,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
