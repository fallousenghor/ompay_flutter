import 'package:flutter/material.dart';

class WelcomePagination extends StatelessWidget {
  const WelcomePagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 15, backgroundColor: Colors.orange),
        const SizedBox(width: 15),
        CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade400),
        const SizedBox(width: 15),
        CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade400),
      ],
    );
  }
}
