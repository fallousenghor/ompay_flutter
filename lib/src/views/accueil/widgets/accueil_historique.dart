import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:flutter_app/src/models/transaction_mdels/transaction.dart';

class AccueilHistorique extends StatefulWidget {
  const AccueilHistorique({Key? key}) : super(key: key);

  @override
  State<AccueilHistorique> createState() => _AccueilHistoriqueState();
}

class _AccueilHistoriqueState extends State<AccueilHistorique> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Delay the fetch to ensure user is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refetch when dependencies change (e.g., user login)
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    if (serviceProvider.currentUser != null &&
        _transactions.isEmpty &&
        !_isLoading) {
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final user = serviceProvider.currentUser;
    if (user != null) {
      final response = await serviceProvider.userService.getDashboard();
      if (response.success && response.data != null) {
        setState(() {
          _transactions = response.data!.transactionsRecentes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        // Refetch if user changes
        if (serviceProvider.currentUser != null &&
            _transactions.isEmpty &&
            !_isLoading) {
          _fetchTransactions();
        }

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFFF97316), size: 20),
                    onPressed: _fetchTransactions,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune transaction récente',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1F2937).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF374151),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getTransactionIcon(transaction.type),
                                        color: const Color(0xFF9CA3AF),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Transaction details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getTransactionTitle(transaction),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDate(
                                                transaction.dateTransaction),
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount
                                    Text(
                                      '${transaction.montant} FCFA',
                                      style: TextStyle(
                                        color: transaction.typeOperation ==
                                                'credit'
                                            ? const Color(0xFF10B981)
                                            : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getTransactionIcon(String? type) {
    switch (type) {
      case 'transfert':
        return Icons.swap_horiz;
      case 'paiement':
        return Icons.payment;
      case 'recharge':
        return Icons.add_circle;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _getTransactionTitle(Transaction transaction) {
    switch (transaction.type) {
      case 'transfert':
        return 'Transfert';
      case 'paiement':
        return 'Paiement';
      case 'recharge':
        return 'Recharge';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
