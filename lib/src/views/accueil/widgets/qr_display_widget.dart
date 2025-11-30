import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_app/src/models/transaction_mdels/qrcode.dart' as models;
import 'package:flutter_app/src/theme/app_colors.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/views/login/code_pin/pin_page.dart';

class QrDisplayWidget extends StatefulWidget {
  final models.QrCode qrCode;

  const QrDisplayWidget({super.key, required this.qrCode});

  @override
  State<QrDisplayWidget> createState() => _QrDisplayWidgetState();
}

class _QrDisplayWidgetState extends State<QrDisplayWidget> {
  bool isSoundEnabled = true;
  bool isScannerActive = true; // Scanner active by default
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _processScanResult(scanData.code!);
      }
    });
  }

  Future<void> _processScanResult(String scannedCode) async {
    // Stop scanning
    controller?.pauseCamera();

    try {
      final context = this.context;
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      final numeroCompte = serviceProvider.currentUser?.numeroTelephone;

      if (numeroCompte == null) {
        _showError(context, 'Utilisateur non connecté');
        controller?.resumeCamera();
        return;
      }

      // Scanner le QR code
      final response = await serviceProvider.paiementService
          .scannerQRCode(scannedCode, numeroCompte);

      if (response.success && response.data != null) {
        // Récupérer les données du QR code
        final data = response.data!.data;

        // Navigate to PIN confirmation page for payment
        // ignore: use_build_context_synchronously
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinCodeEntryPage(
              isFirstLogin: false,
              phoneNumber: numeroCompte,
              operationType: 'paiement',
              operationId: data['idPaiement'] as String? ?? '',
            ),
          ),
        );

        if (result == true) {
          // Payment successful, close dialog
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          controller?.resumeCamera();
        }
      } else {
        _showError(
            context, response.message ?? 'Erreur lors du scan du QR code');
        controller?.resumeCamera();
      }
    } catch (e) {
      _showError(context, 'Erreur: $e');
      controller?.resumeCamera();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Scanner and Mon QR buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isScannerActive = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isScannerActive
                            ? AppColors.lightPrimary
                            : Colors.grey[300],
                        foregroundColor: isScannerActive
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Scanner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isScannerActive = false;
                        });
                      },
                      child: Text(
                        'Mon QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !isScannerActive
                              ? AppColors.lightPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56), // Space for menu button area
                ],
              ),
            ),
            // QR Code Display Area or Scanner
            if (isScannerActive)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 280),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.transparent,
                            borderRadius: 16,
                            borderLength: 30,
                            borderWidth: 8,
                            cutOutSize: 250,
                          ),
                        ),
                      ),
                    ),
                    // Sound button - positioned at bottom right
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isSoundEnabled = !isSoundEnabled;
                              });
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                isSoundEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                color: AppColors.lightPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 280),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[600]!,
                            Colors.grey[400]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: widget.qrCode.donnees,
                            size: 200,
                            // ignore: deprecated_member_use
                            foregroundColor: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Sound button - positioned at bottom right
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isSoundEnabled = !isSoundEnabled;
                              });
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                isSoundEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                color: AppColors.lightPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
