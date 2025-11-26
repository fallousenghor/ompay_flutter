import 'package:flutter/material.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/models/transaction_mdels/transaction_models.dart';
import 'package:flutter_app/src/services/services.dart';
import 'package:flutter_app/src/views/login/code_pin/pin_page.dart';

import 'widgets/accueil_header.dart';
import 'package:flutter_app/src/views/dashboard/dashboard_drawer.dart';
import 'widgets/accueil_tabs.dart';
import 'widgets/accueil_form.dart';
import 'widgets/accueil_maxit.dart';
import 'widgets/accueil_historique.dart';

class OrangeMoneyHomePage extends StatefulWidget {
  const OrangeMoneyHomePage({Key? key}) : super(key: key);

  @override
  State<OrangeMoneyHomePage> createState() => _OrangeMoneyHomePageState();
}

class _OrangeMoneyHomePageState extends State<OrangeMoneyHomePage> {
  int _selectedTab = 0; // 0 = Payer, 1 = Transférer
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch user profile and balance when page initializes
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.fetchUserProfile();
    serviceProvider.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18171C),
      drawer: const DashboardDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Builder(
                  builder: (context) => AccueilHeader(
                    openDrawer: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            AccueilTabs(
                              selectedTab: _selectedTab,
                              onTabChanged: (i) =>
                                  setState(() => _selectedTab = i),
                            ),
                            const SizedBox(height: 8),
                            AccueilForm(
                              selectedTab: _selectedTab,
                              numeroController: _numeroController,
                              montantController: _montantController,
                              onValidate: _onValidate,
                            ),
                            const SizedBox(height: 12),
                            const AccueilMaxItSection(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: AccueilHistorique(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onValidate() async {
    final numero = _numeroController.text.trim();
    final montantText = _montantController.text.trim();

    if (numero.isEmpty || montantText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);

    try {
      if (_selectedTab == 0) {
        // Payment - détecter automatiquement le type d'entrée
        final numeroCompte = serviceProvider.currentUser!.numeroTelephone;

        // Détecter si c'est un numéro de téléphone (commence par +221 ou 7) ou un code marchand
        bool isPhoneNumber =
            numero.startsWith('+221') || numero.startsWith('7');

        ApiResponse<Map<String, dynamic>> response;
        if (isPhoneNumber) {
          // Paiement par numéro de téléphone
          response = await serviceProvider.paiementService
              .saisirNumeroTelephone(numero, montant, numeroCompte);
        } else {
          // Paiement par code marchand
          response = await serviceProvider.paiementService
              .saisirCodePaiement(numero, montant, numeroCompte);
        }

        if (response.success && response.data != null) {
          // Navigate to PIN confirmation page for payment
          // ignore: use_build_context_synchronously
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PinCodeEntryPage(
                isFirstLogin: false,
                phoneNumber: numeroCompte,
                operationType: 'paiement',
                operationId: response.data!['idPaiement'] as String,
              ),
            ),
          );
          if (result == true) {
            _numeroController.clear();
            _montantController.clear();
            serviceProvider.fetchBalance();
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.message}')),
          );
        }
      } else {
        // Transfer
        final numeroCompte = serviceProvider.currentUser?.numeroTelephone;
        if (numeroCompte == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
          );
          return;
        }
        final request = InitiateTransfertRequest(
          telephoneDestinataire: numero,
          montant: montant,
        );
        final response = await serviceProvider.transfertService
            .initierTransfert(numeroCompte, request);
        if (response.success) {
          // Navigate to PIN confirmation page
          // ignore: use_build_context_synchronously
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PinCodeEntryPage(
                isFirstLogin: false,
                phoneNumber: numeroCompte,
                operationType: 'transfert',
                operationId: response.data!.idTransfert,
              ),
            ),
          );
          if (result == true) {
            _numeroController.clear();
            _montantController.clear();
            serviceProvider.fetchBalance();
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.message}')),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _montantController.dispose();
    super.dispose();
  }
}
