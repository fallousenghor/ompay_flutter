import 'package:flutter/material.dart';
import 'widgets/welcome_header.dart';
import 'widgets/welcome_pagination.dart';
import 'widgets/welcome_form.dart';
import 'widgets/welcome_footer.dart';

class OMPayScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  OMPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D3D3D),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WelcomeHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: WelcomePagination(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            WelcomeForm(phoneController: phoneController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            const WelcomeFooter(),
          ],
        ),
      ),
    );
  }
}
