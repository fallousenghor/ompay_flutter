import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final headerHeight = screenSize.height * 0.35; // Responsive height

    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  "assets/images/bgi.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: screenSize.width * 0.05, // Responsive left padding
              bottom: headerHeight * 0.25, // Responsive bottom position
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/logor.png",
                        height: isSmallScreen ? 35 : 50,
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.orange,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 24 : 33,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6B00),
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.money,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 23 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.transfer,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 25,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF6B00),
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.moneyTransfer,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: screenSize.width * 0.7, // Responsive width
                    child: Text(
                      AppLocalizations.of(context)!.sendQuickly,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 12 : 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.95,
      size.width * 0.50,
      size.height * 0.88,
    );
    path.quadraticBezierTo(
      size.width * 0.80,
      size.height * 0.80,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
