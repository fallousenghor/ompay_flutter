import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Icons

              const SizedBox(height: 32),

              // Title
              const Text(
                "Retrait d'argent",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // Transaction Details
              _buildDetailRow('Destinataire', '786413005'),
              _buildDetailRow('Expéditeur', '782463262'),
              _buildDetailRow('Montant', '2 000 CFA'),
              _buildDetailRow('Date', '28/08/2025 15:53'),
              _buildDetailRow('Référence', 'C0250828.1553.D99373'),

              const SizedBox(height: 24),

              // Footer text
              const Text(
                "Reçu généré par l'application OM PAY",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Share button
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  iconSize: 24,
                  onPressed: () {},
                  padding: const EdgeInsets.all(16),
                ),
              ),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(
      IconData icon, List<Color> gradientColors, List<Color> borderColors) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColors[0], width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(2, 2),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColors[1], width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
