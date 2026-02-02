import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/task_controller.dart'; 
import '../../models/transaction_model.dart';
import '../widgets/add_transaction_dialog.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FinanceController>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8)
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Gestão Financeira", 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.attach_money, color: Colors.white),
        label: Text("Nova Transação", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        onPressed: () {
          showDialog(
            context: context, 
            builder: (_) => const AddTransactionDialog()
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SALDO TOTAL", style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(controller.balance), 
                    style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildMiniStat(Icons.arrow_upward, "Receitas", "+ ${currencyFormat.format(controller.totalIncome)}", Colors.greenAccent),
                      const SizedBox(width: 24),
                      _buildMiniStat(Icons.arrow_downward, "Despesas", "- ${currencyFormat.format(controller.totalExpense)}", Colors.redAccent),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text("ÚLTIMAS MOVIMENTAÇÕES", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(context, controller.transactions[index], currencyFormat);
              },
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        )
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction, NumberFormat formatter) {
    final dateStr = DateFormat('dd MMM, HH:mm', 'pt_BR').format(transaction.date);
    final isCTO = context.read<TaskController>().isManager;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10)
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isIncome ? const Color(0xFF2EA063).withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle
            ),
            child: Icon(
              transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward, 
              color: transaction.isIncome ? const Color(0xFF2EA063) : Colors.red, 
              size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title, 
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                ),
                Text(
                  "${transaction.category} • $dateStr", 
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          Text(
            "${transaction.isIncome ? '+' : '-'} ${formatter.format(transaction.value)}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, 
              color: transaction.isIncome ? const Color(0xFF2EA063) : Colors.white
            ),
          ),

          if (isCTO) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              tooltip: "Remover (Apenas CTO)",
              onPressed: () => _confirmDelete(context, transaction.id),
            )
          ]
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final passController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Autorização Requerida", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Esta ação é irreversível. Digite a senha administrativa:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                hintText: "Senha do CTO",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey))
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (passController.text == 'admin') {
                context.read<FinanceController>().removeTransaction(id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Transação removida com sucesso."),
                    backgroundColor: Colors.green,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Senha incorreta! Acesso negado.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25), textAlign: TextAlign.center),
                    backgroundColor: Color.fromARGB(255, 240, 16, 0),
                  )
                );
              }
            }, 
            child: const Text("Confirmar")
          ),
        ],
      ),
    );
  }
}