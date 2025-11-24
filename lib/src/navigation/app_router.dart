import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/views/welcome/welcome_page.dart';
import 'package:flutter_app/src/views/login/verification_otp/opt_page.dart';
import 'package:flutter_app/src/views/login/code_pin/pin_page.dart';
import 'package:flutter_app/src/views/accueil/accueil_page.dart';

/// Classe centralisée pour la gestion des routes de l'application
class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => OMPayScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OTPVerificationPage(
            phoneNumber: extra['phoneNumber'] ?? '',
            token: extra['token'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final isFirst = extra['isFirstLogin'] as bool? ?? false;
          final phone = extra['phoneNumber'] as String? ?? '';
          final token = extra['token'] as String? ?? '';
          return PinCodeEntryPage(
            isFirstLogin: isFirst,
            phoneNumber: phone,
            token: token,
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const OrangeMoneyHomePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page non trouvée: ${state.uri}')),
    ),
  );

  // ...
}
