import 'package:flutter/material.dart';

class Pi extends StatelessWidget {
  const Pi({super.key});

  @override
  Widget build(BuildContext context) {
    return const IconTheme(
      data: IconThemeData(
        size: 28,
        color: Colors.white,
      ),
      child: Text(
        'π',
        style: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
// ignore: non_constant_identifier_names
