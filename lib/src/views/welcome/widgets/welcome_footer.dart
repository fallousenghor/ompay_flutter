import 'package:flutter/material.dart';

class WelcomeFooter extends StatelessWidget {
  const WelcomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Padding(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05,
        bottom: screenSize.height * 0.03,
        left: screenSize.width * 0.08,
        right: screenSize.width * 0.08,
      ),
      child: Text(
        "© Copyright - Orange Money Group, tous droits réservés",
        style: TextStyle(
          fontSize: isSmallScreen ? 10 : 12,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
