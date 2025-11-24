import 'package:flutter/material.dart';
import 'widgets/accueil_header.dart';
import 'package:flutter_app/src/views/dashboard/dashboard_drawer.dart';
import 'widgets/accueil_tabs.dart';
import 'widgets/accueil_form.dart';
import 'widgets/accueil_maxit.dart';
import 'widgets/accueil_historique.dart';

class OrangeMoneyHomePage extends StatefulWidget {
  const OrangeMoneyHomePage({Key? key}) : super(key: key);

  @override
  State<OrangeMoneyHomePage> createState() => _OrangeMoneyHomePageState();
}

class _OrangeMoneyHomePageState extends State<OrangeMoneyHomePage> {
  int _selectedTab = 0; // 0 = Payer, 1 = Transférer
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18171C),
      drawer: const DashboardDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (context) => AccueilHeader(
                openDrawer: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    AccueilTabs(
                      selectedTab: _selectedTab,
                      onTabChanged: (i) => setState(() => _selectedTab = i),
                    ),
                    const SizedBox(height: 12),
                    AccueilForm(
                      numeroController: _numeroController,
                      montantController: _montantController,
                    ),
                    const SizedBox(height: 18),
                    const AccueilMaxItSection(),
                    const SizedBox(height: 18),
                    const AccueilHistorique(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _montantController.dispose();
    super.dispose();
  }
}

// Simple QR Code painter (simulé)
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Simulation d'un QR code avec des carrés
    final blockSize = size.width / 10;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * blockSize,
              j * blockSize,
              blockSize * 0.9,
              blockSize * 0.9,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
