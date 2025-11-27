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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final horizontalPadding = screenSize.width * 0.08; // 8% of screen width

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Text(
            "Bienvenue sur OM Pay!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Entrez votre numéro mobile pour\nvous connecter",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenSize.height * 0.04),
          TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Saisir mon numéro (771234567)",
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFF6B00), width: 2),
              ),
              errorText: _errorMessage,
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
          SizedBox(height: screenSize.height * 0.03),
          ElevatedButton(
            onPressed: _isLoading ? null : _initiateLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              minimumSize: Size(double.infinity, isSmallScreen ? 44 : 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
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
                : Text(
                    "Se connecter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
