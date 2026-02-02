import 'dart:convert';
import 'package:flutter/foundation.dart'; // Necessário para kIsWeb
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _financeBoxName = 'finance_box_secure';
  static const String _tasksBoxName = 'tasks_box_secure';
  static const String _settingsBoxName = 'settings_box_secure'; // Para salvar categorias

  // 🔑 CHAVE DE CRIPTOGRAFIA (AES-256)
  static final List<int> _secureKey = utf8.encode('AzorTech_Key_2026_Secure_32Bytes'); 

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // BLINDAGEM CONDICIONAL: 
    // Web não suporta EncryptionCipher no IndexedDB nativamente.
    // Se for Web, abrimos sem criptografia (o browser já isola o storage).
    // Se for Mobile/Desktop, usamos AES-256.
    final cipher = kIsWeb ? null : HiveAesCipher(_secureKey);

    await Hive.openBox(_financeBoxName, encryptionCipher: cipher);
    await Hive.openBox(_tasksBoxName, encryptionCipher: cipher);
    await Hive.openBox(_settingsBoxName, encryptionCipher: cipher);
  }

  // --- CRUD FINANCEIRO ---
  static Box get _financeBox => Hive.box(_financeBoxName);

  static Future<void> saveTransaction(Map<String, dynamic> item) async => await _financeBox.put(item['id'], item);
  static Future<void> deleteTransaction(String id) async => await _financeBox.delete(id);
  static List<Map<dynamic, dynamic>> getAllTransactions() {
    if (_financeBox.isEmpty) return [];
    return _financeBox.values.map((e) => Map<dynamic, dynamic>.from(e as Map)).toList();
  }

  // --- CRUD TAREFAS (KANBAN) ---
  static Box get _tasksBox => Hive.box(_tasksBoxName);

  static Future<void> saveTask(Map<String, dynamic> item) async => await _tasksBox.put(item['id'], item);
  static Future<void> deleteTask(String id) async => await _tasksBox.delete(id);
  static List<Map<dynamic, dynamic>> getAllTasks() {
    if (_tasksBox.isEmpty) return [];
    return _tasksBox.values.map((e) => Map<dynamic, dynamic>.from(e as Map)).toList();
  }

  // --- CONFIGURAÇÕES (CATEGORIAS) ---
  static Box get _settingsBox => Hive.box(_settingsBoxName);

  static Future<void> saveCategories(List<String> categories) async {
    await _settingsBox.put('custom_categories', categories);
  }

  static List<String> getCategories() {
    final list = _settingsBox.get('custom_categories');
    if (list != null) return List<String>.from(list);
    return []; // Retorna vazio se não tiver nada salvo
  }

  static Future<void> clearAll() async {
    await _financeBox.clear();
    await _tasksBox.clear();
    await _settingsBox.clear();
  }
}