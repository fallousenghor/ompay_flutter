import 'package:flutter/material.dart';
// Provider/backend calls are now handled by the OTP page when needed.
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

    // Navigate immediately to OTP page and let the OTP page request the token
    // if it's missing. This improves UX and allows testing the OTP UI
    // even if the backend call is still pending or fails.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Redirection vers la page de vérification...')),
      );
      GoRouter.of(context).go('/otp', extra: {
        'phoneNumber': formattedPhoneNumber,
        'token': '',
      });
    });

    if (mounted) {
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
