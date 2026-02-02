import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class FinanceController extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  final List<TransactionModel> _transactions = [
    // Dados iniciais para não ficar vazio
    TransactionModel(id: '1', title: 'Projeto Web - Landing Page', value: 4500.00, date: DateTime.now(), isIncome: true),
    TransactionModel(id: '2', title: 'Servidor VPS (Hetzner)', value: 120.00, date: DateTime.now().subtract(const Duration(days: 1)), isIncome: false),
    TransactionModel(id: '3', title: 'Consultoria UX/UI', value: 1200.00, date: DateTime.now().subtract(const Duration(days: 2)), isIncome: true),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  double get balance {
    double total = 0;
    for (var t in _transactions) {
      if (t.isIncome) {
        total += t.value;
      } else {
        total -= t.value;
      }
    }
    return total;
  }

  double get totalIncome {
    return _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.value);
  }

  double get totalExpense {
    return _transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.value);
  }

  // O método que o Dialog vai chamar
  void addTransaction({required String title, required double value, required bool isIncome, required DateTime date}) {
    final newTransaction = TransactionModel(
      id: _uuid.v7(),
      title: title,
      value: value,
      date: date,
      isIncome: isIncome,
    );

    _transactions.insert(0, newTransaction); // Adiciona no topo da lista
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}