import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../core/utils/input_sanitizer.dart';

class FinanceController extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  // [NOVO] Listas de Categorias Básicas
  final List<String> _incomeCategories = [
    'Projetos', 
    'Consultoria', 
    'Retainer', 
    'Investimento', 
    'Outros'
  ];

  final List<String> _expenseCategories = [
    'Infraestrutura', 
    'Ferramentas (SaaS)', 
    'Pessoal', 
    'Marketing', 
    'Escritório', 
    'Impostos',
    'Outros'
  ];

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1', 
      title: 'Projeto Web - Landing Page', 
      value: 4500.00, 
      date: DateTime.now(), 
      isIncome: true,
      category: 'Projetos'
    ),
    TransactionModel(
      id: '2', 
      title: 'Servidor VPS (Hetzner)', 
      value: 120.00, 
      date: DateTime.now().subtract(const Duration(days: 1)), 
      isIncome: false,
      category: 'Infraestrutura'
    ),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  
  // [NOVO] Getters para expor as categorias
  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);

  double get balance {
    double total = 0;
    for (var t in _transactions) {
      if (t.isIncome) total += t.value;
      else total -= t.value;
    }
    return total;
  }

  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.value);
  double get totalExpense => _transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.value);

  // [NOVO] Método para criar categoria (com sanitização)
  void addCategory(String name, bool isIncome) {
    final cleanName = InputSanitizer.clean(name);
    if (cleanName.isEmpty) return;

    if (isIncome) {
      if (!_incomeCategories.contains(cleanName)) {
        _incomeCategories.add(cleanName);
        notifyListeners();
      }
    } else {
      if (!_expenseCategories.contains(cleanName)) {
        _expenseCategories.add(cleanName);
        notifyListeners();
      }
    }
  }

  void addTransaction({
    required String title, 
    required double value, 
    required bool isIncome, 
    required DateTime date,
    required String category // [NOVO] Agora exige categoria
  }) {
    final newTransaction = TransactionModel(
      id: _uuid.v7(),
      title: title,
      value: value,
      date: date,
      isIncome: isIncome,
      category: category,
    );

    _transactions.insert(0, newTransaction);
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}