import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:go_router/go_router.dart';

class PinCodeEntryPage extends StatefulWidget {
  final bool isFirstLogin;
  final String phoneNumber;
  final String token;
  final String? operationType; // 'transfert', 'paiement', etc.
  final String? operationId; // ID du transfert ou paiement à confirmer

  const PinCodeEntryPage({
    Key? key,
    required this.isFirstLogin,
    required this.phoneNumber,
    this.token = '',
    this.operationType,
    this.operationId,
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
    print(
        '_authenticateWithPin called with operationType: ${widget.operationType}, pinCode length: ${_pinCode.length}');
    if (_pinCode.length != _pinLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      if (widget.operationType == 'transfert' && widget.operationId != null) {
        // Confirmation de transfert
        final numeroCompte = serviceProvider.currentUser!.numeroTelephone;
        final result =
            await serviceProvider.transfertService.confirmerTransfert(
          numeroCompte,
          widget.operationId!,
          _pinCode,
        );

        if (result.success) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfert confirmé avec succès')),
          );
          // Do not navigate, let user click "Fermer" to close
        } else {
          setState(() {
            _errorMessage = result.message ?? 'Erreur lors de la confirmation';
            _pinCode = '';
          });
        }
      } else if (widget.operationType == 'paiement' &&
          widget.operationId != null) {
        // Confirmation de paiement
        final numeroCompte = serviceProvider.currentUser!.numeroTelephone;
        final result = await serviceProvider.paiementService.confirmerPaiement(
          widget.operationId!,
          _pinCode,
          numeroCompte,
        );

        if (result.success) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement confirmé avec succès')),
          );
          // Do not navigate, let user click "Fermer" to close
        } else {
          setState(() {
            _errorMessage = result.message ?? 'Erreur lors de la confirmation';
            _pinCode = '';
          });
        }
      } else if (widget.isFirstLogin) {
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
          setState(() {
            _isLoading = false;
          });
          _navigateToHome();
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
            if (result.data!.user != null) {
              serviceProvider.setCurrentUser(result.data!.user!);
            }
            debugPrint(
                'PIN login succeeded, sessionToken=${result.data!.sessionToken}');
          } else {
            debugPrint('login succeeded but no sessionToken provided');
          }
          setState(() {
            _isLoading = false;
          });
          _navigateToHome();
        } else {
          setState(() {
            _errorMessage = result.message ?? 'Code PIN incorrect';
            _pinCode = '';
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
    print('_navigateToHome called with operationType: ${widget.operationType}');
    // Pour les opérations, revenir à la page précédente (accueil)
    // Pour les connexions, aller à l'accueil
    if (widget.operationType != null) {
      print('Popping to previous page');
      Navigator.of(context).pop();
    } else {
      print('Going to /home');
      context.go('/home');
    }
  }

  void _onNumberPressed(String number) {
    if (_pinCode.length < _pinLength) {
      setState(() {
        _pinCode += number;
      });

      // Auto-confirm only for login/first login, not for operations
      if (_pinCode.length == _pinLength && widget.operationType == null) {
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
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.operationType == 'transfert'
                          ? "Confirmation de transfert"
                          : widget.operationType == 'paiement'
                              ? "Confirmation de paiement"
                              : "SMS d'authentification vérifié !",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.operationType == 'transfert'
                          ? 'Veuillez saisir votre code PIN pour confirmer le transfert'
                          : widget.operationType == 'paiement'
                              ? 'Veuillez saisir votre code PIN pour confirmer le paiement'
                              : widget.isFirstLogin
                                  ? 'Veuillez créer votre code secret Orange Money !'
                                  : 'Veuillez saisir votre code secret Orange Money !',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 7),
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
                    const SizedBox(height: 16),
                    // Clavier numérique custom
                    _buildPinKeyboard(),
                    const SizedBox(height: 12),
                    // Bouton Confirmer (seulement pour les opérations)
                    if (widget.operationType != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _pinCode.length == _pinLength
                              ? () {
                                  print('Confirmer button pressed');
                                  _authenticateWithPin();
                                }
                              : null,
                          child: const Text(
                            'Confirmer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
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
                        onPressed: () => Navigator.pop(
                            context, widget.operationType != null),
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
