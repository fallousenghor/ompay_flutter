import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/navigation/app_router.dart';
import 'package:flutter_app/src/views/accueil/accueil_page.dart';

class PinCodeEntryPage extends StatefulWidget {
  final bool isFirstLogin;
  final String phoneNumber;
  final String token;

  const PinCodeEntryPage({
    Key? key,
    required this.isFirstLogin,
    required this.phoneNumber,
    this.token = '',
  }) : super(key: key);

  @override
  State<PinCodeEntryPage> createState() => _PinCodeEntryPageState();
}

class _PinCodeEntryPageState extends State<PinCodeEntryPage> {
  String _pinCode = '';
  final int _pinLength = 4;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticateWithPin() async {
    if (_pinCode.length != _pinLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      if (widget.isFirstLogin) {
        // Create account using token from OTP verification
        final result = await serviceProvider.authService.createAccount(
          CreateAccountRequest(
            numeroTelephone: widget.phoneNumber,
            codePin: _pinCode,
            token: widget.token,
          ),
        );

        if (result.success) {
          // If server returned a session token, store it.
          if (result.data != null && result.data!.sessionToken.isNotEmpty) {
            serviceProvider.setAuthToken(result.data!.sessionToken);
            debugPrint(
                'PIN createAccount succeeded, sessionToken=${result.data!.sessionToken}');
          } else {
            debugPrint('createAccount succeeded but no sessionToken provided');
          }
          // Navigate to home even if server didn't return a session token
          // (server may use another auth mechanism). This mirrors server
          // behaviour where success=true indicates account created.
          try {
            _navigateToHome();
          } catch (e, st) {
            debugPrint('Navigation to home failed: $e\n$st');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigation failed: $e')),
              );
            }
          }
        } else {
          setState(() {
            _errorMessage = result.message ?? 'Erreur création de compte';
            _pinCode = '';
          });
        }
      } else {
        // Regular login with PIN
        final result = await serviceProvider.authService.login(
          LoginRequest(
            numeroTelephone: widget.phoneNumber,
            codePin: _pinCode,
          ),
        );

        if (result.success) {
          if (result.data != null && result.data!.sessionToken.isNotEmpty) {
            serviceProvider.setAuthToken(result.data!.sessionToken);
            debugPrint(
                'PIN login succeeded, sessionToken=${result.data!.sessionToken}');
          } else {
            debugPrint('login succeeded but no sessionToken provided');
          }
          _navigateToHome();
        } else {
          setState(() {
            _errorMessage = result.message ?? 'Code PIN incorrect';
            _pinCode = ''; // Reset PIN on error
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
        _pinCode = ''; // Reset PIN on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    debugPrint('Scheduling navigation to /home (delayed)');
    Future.delayed(const Duration(milliseconds: 250), () async {
      // Try GoRouter using the current BuildContext first (preferred)
      if (mounted) {
        try {
          debugPrint('Attempting GoRouter.of(context).go("/home")');
          GoRouter.of(context).go('/home');
          debugPrint('GoRouter.of(context).go succeeded');
          return;
        } catch (e, st) {
          debugPrint('GoRouter.of(context).go failed: $e\n$st');
        }
      } else {
        debugPrint('Context not mounted when navigating via GoRouter.of(context)');
      }

      // Try the static router instance as a fallback
      try {
        debugPrint('Attempting AppRouter.router.go("/home")');
        AppRouter.router.go('/home');
        debugPrint('AppRouter.router.go succeeded');
        return;
      } catch (e, st) {
        debugPrint('AppRouter.router.go failed: $e\n$st');
      }

      // Last-resort: Navigator push replacement using root navigator
      try {
        debugPrint('Attempting Navigator.of(rootNavigator).pushAndRemoveUntil');
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const OrangeMoneyHomePage()),
          (route) => false,
        );
        debugPrint('Navigator fallback succeeded');
      } catch (e, st) {
        debugPrint('Navigator fallback also failed: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigation failed: $e')),
          );
        }
      }
    });
  }

  void _onNumberPressed(String number) {
    if (_pinCode.length < _pinLength) {
      setState(() {
        _pinCode += number;
      });

      if (_pinCode.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 200), _authenticateWithPin);
      }
    }
  }

  void _onDeletePressed() {
    if (_pinCode.isNotEmpty) {
      setState(() {
        _pinCode = _pinCode.substring(0, _pinCode.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _pinCode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Image de fond
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay foncé
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
            // color: Colors.black.withOpacity(0.55),
          ),
          // Carte PIN centrée
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF23232B),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logos centrés
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logor.png',
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "SMS d'authentification vérifié !",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isFirstLogin
                        ? 'Veuillez créer votre code secret Orange Money !'
                        : 'Veuillez saisir votre code secret Orange Money !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Indicateurs de code PIN
                  _isLoading
                      ? const SizedBox(
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pinLength, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 7),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < _pinCode.length
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.25),
                              ),
                            );
                          }),
                        ),
                  const SizedBox(height: 22),
                  // Clavier numérique custom
                  _buildPinKeyboard(),
                  const SizedBox(height: 18),
                  // Bouton Fermer
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinKeyboard() {
    // Disposition fidèle à la maquette : 3 rangées de chiffres, puis delete et clear
    final List<List<String>> keys = [
      ['9', '3', '0', '7'],
      ['4', '6', '1', '5'],
      ['2', '8', 'x', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key == 'x') {
                return _buildActionButton(
                  icon: Icons.close,
                  onPressed: _onDeletePressed,
                  color: Colors.white,
                  isOrange: false,
                );
              } else if (key == 'del') {
                return _buildActionButton(
                  icon: Icons.delete,
                  onPressed: _onClearPressed,
                  color: const Color(0xFFFF6B00),
                  isOrange: true,
                );
              } else {
                return _buildNumberButton(key);
              }
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isOrange = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isOrange ? color : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: isOrange ? Colors.white : Colors.black87,
            size: 28,
          ),
        ),
      ),
    );
  }
}
