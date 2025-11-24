import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();

      Map<String, dynamic>? extra;
      try {
        final state = GoRouterState.of(context);
        extra = state.extra as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('GoRouterState.of failed: $e');
      }

      if (extra == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          extra = args;
        }
      }

      if (extra != null) {
        _phoneNumber = extra['phoneNumber'] as String? ?? '';
        _token = extra['token'] as String? ?? '';
      } else {
        _phoneNumber = widget.phoneNumber;
        _token = widget.token;
      }

      debugPrint(
          'OTP Page initialized: phone=$_phoneNumber, token=${_token.isNotEmpty ? "present" : "empty"}');

      // Validate required data
      if (_phoneNumber.isEmpty) {
        setState(() {
          _errorMessage = 'Numéro de téléphone manquant';
        });
        return;
      }

      if (_token.isEmpty) {
        // Request a token to be sent to the phone number
        _requestToken();
      }
    });
  }

  Future<void> _requestToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prevent concurrent verify requests
      if (_isVerifying) {
        debugPrint('verifyOtp: already verifying, aborting duplicate call');
        return;
      }
      _isVerifying = true;
      if (!mounted) return;
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      // Normalize phone number for backend: ensure +221 prefix when needed
      String normalizedPhone = _phoneNumber.trim();
      if (!normalizedPhone.startsWith('+')) {
        if (normalizedPhone.startsWith('0')) {
          normalizedPhone = '+221' + normalizedPhone.substring(1);
        } else if (RegExp(r'^7\d{7,}$').hasMatch(normalizedPhone)) {
          normalizedPhone = '+221$normalizedPhone';
        }
      }

      debugPrint('Requesting OTP token for $normalizedPhone');

      final result = await serviceProvider.authService.initiateLogin(
        InitiateLoginRequest(numeroTelephone: normalizedPhone),
      );

      if (result.success && result.data != null) {
        final received = result.data!.token ?? '';
        if (received.isNotEmpty) {
          if (mounted) {
            setState(() {
              _token = received;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code OTP envoyé')),
            );
            debugPrint('requestToken: token=$received');
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = result.message ?? 'Aucun token reçu du serveur';
            });
          }
          debugPrint(
              'requestToken: success but token empty, result=${result.message}');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                result.message ?? 'Erreur lors de la demande du code OTP';
          });
        }
        debugPrint('requestToken failed: ${result.message}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

    // Ensure we have a token before verifying. If it's missing, request one.
    if (_token.isEmpty) {
      await _requestToken();
      if (_token.isEmpty) {
        setState(() {
          _errorMessage = 'Impossible de vérifier : token manquant';
          _isLoading = false;
        });
        return;
      }
    }

    try {
      if (!mounted) return;
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      debugPrint('verifyOtp request -> token=$_token, code=$otp');
      final result = await serviceProvider.authService.verifyOtp(
        VerifyOtpRequest(token: _token, code: otp),
      );
      debugPrint(
          'verifyOtp result -> success=${result.success}, message=${result.message}, data=${result.data}');

      if (result.success && result.data != null) {
        final response = result.data!;

        // Debug: log verification response status and phone/token
        debugPrint(
            'verifyOtp: status=${response.status}, phone=$_phoneNumber, token=$_token');

        final bool isFirstLogin = response.status == 'user_created' ||
            response.status == 'user_linked';
        if (!mounted) return;
        debugPrint(
            'Navigating to /pin (isFirstLogin=$isFirstLogin) with phone=$_phoneNumber');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFirstLogin
                ? 'Redirection vers création de PIN...'
                : 'Redirection vers saisie du PIN...'),
          ),
        );
        GoRouter.of(context).go('/pin', extra: {
          'isFirstLogin': isFirstLogin,
          'phoneNumber': _phoneNumber,
          'token': _token,
        });
      } else {
        // If success but no data, or outright failure, surface more debug info
        final serverMsg = result.message ?? 'Code OTP invalide ou expiré';
        final raw = result.data != null ? ' | data: ${result.data}' : '';
        debugPrint(
            'verifyOtp failed: success=${result.success} message=${result.message} data=${result.data}');

        if (kDebugMode && mounted) {
          // Show a debug dialog with raw server response to help diagnose
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Debug verifyOtp'),
              content: SingleChildScrollView(
                child: Text(
                    'success=${result.success}\nmessage=${result.message}\ndata=${result.data}'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        }

        if (mounted) {
          setState(() {
            _errorMessage = '$serverMsg$raw';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _isVerifying = false;
      }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code OTP renvoyé')),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = result.message ?? 'Erreur lors du renvoi du code';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (kDebugMode) ...[
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Debug token'),
                              content: Text(
                                  _token.isNotEmpty ? _token : 'token vide'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Afficher token (debug)'),
                      ),
                      const SizedBox(height: 8),
                    ],
                    OTPCard(
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

                            // Auto-verify when all 6 digits are entered.
                            // Add a short delay and a guard to avoid duplicate requests
                            if (_isOtpComplete() &&
                                !_isLoading &&
                                !_isVerifying) {
                              debugPrint(
                                  '🔄 Scheduling auto-verify OTP: ${_getOtpCode()}');
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                if (!_isLoading &&
                                    !_isVerifying &&
                                    _isOtpComplete()) {
                                  debugPrint(
                                      '🔄 Auto-verifying OTP (delayed): ${_getOtpCode()}');
                                  _verifyOtp();
                                }
                              });
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
                        GoRouter.of(context).go('/');
                      },
                    ),
                  ],
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
