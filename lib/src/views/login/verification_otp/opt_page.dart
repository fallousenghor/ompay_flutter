import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import 'widgets/otp_background.dart';
import 'widgets/otp_logo_row.dart';
import 'widgets/otp_card.dart';
import 'widgets/otp_field.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String token;

  const OTPVerificationPage({Key? key, this.phoneNumber = '', this.token = ''})
      : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String _phoneNumber = '';
  String _token = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();

      // Use constructor-provided values (AppRouter passes them via state.extra)
      _phoneNumber = widget.phoneNumber;
      _token = widget.token;

      if (_phoneNumber.isEmpty || _token.isEmpty) {
        _errorMessage = 'Arguments manquants';
      }
    });
  }

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Helper function to check if all OTP fields are filled
  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  // Helper function to get the complete OTP code
  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    String otp = _getOtpCode();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez saisir le code complet à 6 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Verify OTP with backend

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      final result = await serviceProvider.authService.verifyOtp(
        VerifyOtpRequest(token: _token, code: otp),
      );

      if (result.success && result.data != null) {
        final response = result.data!;

        // Handle different verification statuses
        switch (response.status) {
          case 'user_created':
          case 'user_linked':
            // Navigate to PIN creation/setup
            // ignore: use_build_context_synchronously
            GoRouter.of(context).go('/pin', extra: {
              'isFirstLogin': true,
              'phoneNumber': _phoneNumber,
            });
            break;
          case 'logged_in':
            // User already exists, navigate to PIN entry for login
            // ignore: use_build_context_synchronously
            GoRouter.of(context).go('/pin', extra: {
              'isFirstLogin': false,
              'phoneNumber': _phoneNumber,
            });
            break;
          default:
            setState(() {
              _errorMessage = 'Statut de vérification inconnu';
            });
        }
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Code OTP invalide ou expiré';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      final result = await serviceProvider.authService.initiateLogin(
        InitiateLoginRequest(numeroTelephone: _phoneNumber),
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code OTP renvoyé')),
        );
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Erreur lors du renvoi du code';
        });
      }
    } catch (e) {
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
    return Scaffold(
      body: Stack(
        children: [
          const OTPBackground(),
          const OTPLogoRow(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OTPCard(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  otpFieldBuilder: (index, {double width = 45}) {
                    return OTPField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      width: width,
                      onChanged: (value) {
                        setState(() {});
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }

                        // Auto-verify when all 6 digits are entered
                        if (_isOtpComplete() && !_isLoading) {
                          debugPrint('🔄 Auto-verifying OTP: ${_getOtpCode()}');
                          _verifyOtp();
                        }
                      },
                      onTap: () {
                        if (_controllers[index].text.isNotEmpty) {
                          _controllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _controllers[index].text.length,
                          );
                        }
                      },
                    );
                  },
                  onVerify: _verifyOtp,
                  onResend: _resendOtp,
                  onBack: () {
                    GoRouter.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
