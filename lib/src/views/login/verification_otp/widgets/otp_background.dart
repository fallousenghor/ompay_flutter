import 'package:flutter/material.dart';

class OTPBackground extends StatelessWidget {
  const OTPBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          width: double.infinity,
          height: double.infinity,
        ),
      ],
    );
  }
}
