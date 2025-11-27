import 'package:flutter/material.dart';

class WelcomePagination extends StatelessWidget {
  const WelcomePagination({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isSmallScreen ? 12 : 15,
          backgroundColor: const Color(0xFFFF6B00),
        ),
        SizedBox(width: screenSize.width * 0.04),
        CircleAvatar(
          radius: isSmallScreen ? 8 : 10,
          backgroundColor: Colors.grey.shade400,
        ),
        SizedBox(width: screenSize.width * 0.04),
        CircleAvatar(
          radius: isSmallScreen ? 8 : 10,
          backgroundColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}
