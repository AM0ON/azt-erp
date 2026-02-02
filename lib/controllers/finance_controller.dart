import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart'; // Import do Cofre
import '../core/utils/input_sanitizer.dart';

class FinanceController extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  // Listas de Categorias (Poderiam ir pro Hive também futuramente)
  final List<String> _incomeCategories = ['Projetos', 'Consultoria', 'Retainer', 'Investimento', 'Outros'];
  final List<String> _expenseCategories = ['Infraestrutura', 'Ferramentas (SaaS)', 'Pessoal', 'Marketing', 'Escritório', 'Impostos', 'Outros'];

  // Lista na Memória (Sincronizada com o Hive)
  List<TransactionModel> _transactions = [];

  FinanceController() {
    _loadData(); // 🔄 Carrega dados ao iniciar
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);

  double get balance {
    double total = 0;
    for (var t in _transactions) {
      if (t.isIncome) total += t.value; else total -= t.value;
    }
    return total;
  }

  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.value);
  double get totalExpense => _transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.value);

  // 🔄 Carregar do Disco
  void _loadData() {
    final rawData = StorageService.getAllTransactions();
    
    // Converte Mapas do Hive em Objetos Reais
    _transactions = rawData.map((map) => TransactionModel.fromMap(map)).toList();
    
    // Ordena por data (mais recente primeiro)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }

  void addCategory(String name, bool isIncome) {
    final cleanName = InputSanitizer.clean(name);
    if (cleanName.isEmpty) return;

    if (isIncome && !_incomeCategories.contains(cleanName)) {
      _incomeCategories.add(cleanName);
    } else if (!isIncome && !_expenseCategories.contains(cleanName)) {
      _expenseCategories.add(cleanName);
    }
    notifyListeners();
  }

  void addTransaction({
    required String title, 
    required double value, 
    required bool isIncome, 
    required DateTime date,
    required String category
  }) {
    final newTransaction = TransactionModel(
      id: _uuid.v7(),
      title: title,
      value: value,
      date: date,
      isIncome: isIncome,
      category: category,
    );

    // 1. Atualiza Memória
    _transactions.insert(0, newTransaction);
    notifyListeners();

    // 2. Salva no Cofre (Async Fire & Forget)
    StorageService.saveTransaction(newTransaction.toMap());
  }

  void removeTransaction(String id) {
    // 1. Atualiza Memória
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();

    // 2. Remove do Cofre
    StorageService.deleteTransaction(id);
  }
}