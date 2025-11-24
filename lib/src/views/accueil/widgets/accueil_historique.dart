import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccueilHistorique extends StatelessWidget {
  const AccueilHistorique({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.history,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFFFF6B00),
                  size: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Column(
          children: [
            Icon(Icons.insert_drive_file_outlined,
                color: Colors.white24, size: 80),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noTransaction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
