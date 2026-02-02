class TransactionModel {
  final String id;
  final String title;
  final double value;
  final DateTime date;
  final bool isIncome;
  final String category; // [NOVO] Campo adicionado

  TransactionModel({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.isIncome,
    required this.category, // [NOVO] Obrigatório
  });
}