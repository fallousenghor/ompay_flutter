import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:go_router/go_router.dart';

class WelcomeForm extends StatefulWidget {
  final TextEditingController phoneController;
  const WelcomeForm({super.key, required this.phoneController});

  @override
  State<WelcomeForm> createState() => _WelcomeFormState();
}

class _WelcomeFormState extends State<WelcomeForm> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _initiateLogin() async {
    final phoneNumber = widget.phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre numéro de téléphone';
      });
      return;
    }

    // Basic phone number validation (Senegalese format)
    if (!RegExp(r'^7[0678]\d{7}$').hasMatch(phoneNumber)) {
      setState(() {
        _errorMessage =
            'Format de numéro invalide. Utilisez le format 771234567';
      });
      return;
    }

    // Format phone number with +221 prefix for backend
    final formattedPhoneNumber = '+221$phoneNumber';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      final result = await serviceProvider.authService.initiateLogin(
        InitiateLoginRequest(numeroTelephone: formattedPhoneNumber),
      );

      if (result.success && result.data != null) {
        // Navigation vers la page OTP après le succès, dans un post-frame callback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/otp', extra: {
            'phoneNumber': formattedPhoneNumber,
            'token': result.data!.token ?? '',
          });
        });
      } else {
        setState(() {
          _errorMessage =
              result.message ?? 'Erreur lors de l\'initiation de la connexion';
        });
      }
    } catch (e) {
      debugPrint('💥 Exception caught: $e');
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Bienvenue sur OM Pay!",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        const Text(
          "Entrez votre numéro mobile pour\nvous connecter",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Saisir mon numéro (771234567)",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: _errorMessage,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _initiateLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Se connecter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
