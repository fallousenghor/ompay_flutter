import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:flutter_app/src/views/login/code_pin/pin_page.dart';
import 'package:provider/provider.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
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
        height: 400,
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
          children: [
            // Header
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
                  const Expanded(
                    child: Text(
                      'Scanner QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Scanner
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
