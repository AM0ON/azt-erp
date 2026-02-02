class TransactionModel {
  final String id;
  final String title;
  final double value;
  final DateTime date;
  final bool isIncome;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.isIncome,
    required this.category,
  });

  // 💾 Converte Objeto -> Mapa (Para Salvar no Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'date': date.millisecondsSinceEpoch, // Datas viram números
      'isIncome': isIncome,
      'category': category,
    };
  }

  // 📂 Converte Mapa -> Objeto (Para Ler do Hive)
  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Sem Título',
      value: (map['value'] ?? 0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? DateTime.now().millisecondsSinceEpoch),
      isIncome: map['isIncome'] ?? false,
      category: map['category'] ?? 'Geral',
    );
  }
}