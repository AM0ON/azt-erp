import 'package:flutter/material.dart';

class ClientController extends ChangeNotifier {
  // Lista Mockada de Clientes para o Autocomplete funcionar
  final List<String> _clients = [
    'AzorTech',
    'Restaurante Bom Sabor',
    'Mercado do João',
    'Advocacia Silva',
    'Clínica Saúde',
    'PetShop Amigo',
    'Construtora Ideal',
    'TechStart Solutions',
    'Padaria Central'
  ];

  List<String> get clients => _clients;

  // Método para adicionar novo cliente dinamicamente (se precisar no futuro)
  void addClient(String name) {
    if (!_clients.contains(name)) {
      _clients.add(name);
      notifyListeners();
    }
  }
}