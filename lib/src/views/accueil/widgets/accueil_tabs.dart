import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccueilTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  const AccueilTabs(
      {super.key, required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF23232B),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              index: 0,
              icon: Icons.radio_button_checked,
              label: AppLocalizations.of(context)!.payer,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              index: 1,
              icon: Icons.sync_alt,
              label: AppLocalizations.of(context)!.transfer.trim(),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB800),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phishing_outlined,
              color: Color(0xFF23232B),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context,
      {required int index, required IconData icon, required String label}) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B00) : Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
