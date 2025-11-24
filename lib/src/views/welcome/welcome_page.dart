import 'package:flutter/material.dart';
import 'widgets/welcome_header.dart';
import 'widgets/welcome_pagination.dart';
import 'widgets/welcome_form.dart';
import 'widgets/welcome_footer.dart';
import 'package:go_router/go_router.dart';

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
            const WelcomePagination(),
            const SizedBox(height: 60),
            WelcomeForm(phoneController: phoneController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  GoRouter.of(context).go('/otp', extra: {
                    'phoneNumber': '782463262',
                    'token': 'test-token',
                  });
                });
              },
              child: Text('Test Redirection OTP'),
            ),
            const WelcomeFooter(),
          ],
        ),
      ),
    );
  }
}
