import 'package:flutter/material.dart';

class OTPLogoRow extends StatelessWidget {
  const OTPLogoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 20,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B00),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_upward_rounded,
                color: Color(0xFFFF6B00),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFF6B00),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.loyalty_rounded,
                color: Color(0xFFFF6B00),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
