import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_app/src/views/accueil/widgets/qr_display_widget.dart';

class AccueilHeader extends StatefulWidget {
  final VoidCallback? openDrawer;
  const AccueilHeader({super.key, this.openDrawer});

  @override
  State<AccueilHeader> createState() => _AccueilHeaderState();
}

class _AccueilHeaderState extends State<AccueilHeader> {
  bool _isBalanceVisible = true;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = serviceProvider.currentUser;
    final balance = serviceProvider.currentBalance;
    final dashboard = serviceProvider.dashboard;

    final String fullName = user != null
        ? (user.nomComplet.isNotEmpty
            ? '${user.nomComplet} '
            : user.numeroTelephone)
        : 'U';
    final String displayBalance = _isBalanceVisible
        ? (balance != null ? balance.toStringAsFixed(0) : '0')
        : '••••••';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      color: Colors.transparent,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF23232B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // menu row (kept simple)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu,
                                    color: Colors.white, size: 28),
                                onPressed: widget.openDrawer,
                              ),
                            ],
                          ),
                          // welcome + name moved up
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${AppLocalizations.of(context)!.welcome} ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: fullName,
                                    style: const TextStyle(
                                      color: Color(0xFFFFB800),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Text(
                                  displayBalance,
                                  style: const TextStyle(
                                    color: Color(0xFFFFB800),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'FCFA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _toggleBalanceVisibility,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isBalanceVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // small spacer before QR
                    const SizedBox(width: 8),
                    // QR on right, aligned top and slightly moved up
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        onTap: () {
                          if (dashboard?.qrCode != null) {
                            showDialog(
                              context: context,
                              builder: (context) => QrDisplayWidget(
                                qrCode: dashboard!.qrCode!,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: dashboard?.qrCode != null
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      final available = min(
                                          constraints.maxWidth,
                                          constraints.maxHeight);
                                      final qrSize =
                                          available.clamp(0.0, available);
                                      return Center(
                                        child: QrImageView(
                                          data: dashboard!.qrCode!.donnees,
                                          size: qrSize,
                                          gapless: true,
                                          // ignore: deprecated_member_use
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(Icons.qr_code,
                                    size: 96, color: Color(0xFF23232B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
