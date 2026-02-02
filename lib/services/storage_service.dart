import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _financeBoxName = 'finance_box_secure';
  
  // 🔑 CHAVE DE CRIPTOGRAFIA (AES-256)
  // O Hive exige EXATAMENTE 32 bytes (lista de inteiros).
  // Esta string tem 32 caracteres.
  static final List<int> _secureKey = utf8.encode('AzorTech_Key_2026_Secure_32Bytes'); 

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Abre a caixa financeira com a chave segura
    await Hive.openBox(
      _financeBoxName,
      encryptionCipher: HiveAesCipher(_secureKey),
    );
  }

  // --- CRUD FINANCEIRO ---

  static Box get _box => Hive.box(_financeBoxName);

  static Future<void> saveTransaction(Map<String, dynamic> transactionMap) async {
    // Salva usando o ID como chave para busca rápida
    await _box.put(transactionMap['id'], transactionMap);
  }

  static Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  // Retorna a lista de transações convertida corretamente para o formato que o Controller entende
  static List<Map<dynamic, dynamic>> getAllTransactions() {
    if (_box.isEmpty) return [];
    return _box.values.map((e) => Map<dynamic, dynamic>.from(e as Map)).toList();
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}