import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../controllers/finance_controller.dart';
import '../../core/utils/input_sanitizer.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isIncome = true; 
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nova Transação", 
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: "Receita", 
                    isAvailable: true, 
                    isSelected: _isIncome, 
                    color: const Color(0xFF2EA063),
                    onTap: () => setState(() => _isIncome = true)
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    label: "Despesa", 
                    isAvailable: true, 
                    isSelected: !_isIncome, 
                    color: Colors.redAccent,
                    onTap: () => setState(() => _isIncome = false)
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Descrição",
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.description, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), 
                    ],
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Valor (R\$)",
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: _selectedDate, 
                        firstDate: DateTime(2020), 
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                           data: Theme.of(context).copyWith(
                             colorScheme: const ColorScheme.dark(
                               primary: AppColors.primary,
                               surface: AppColors.surface,
                             )
                           ), 
                           child: child!
                         )
                      );
                      if (d != null) setState(() => _selectedDate = d);
                    },
                    child: Container(
                      height: 56, 
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isIncome ? const Color(0xFF2EA063) : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({required String label, required bool isAvailable, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.black26,
          border: Border.all(color: isSelected ? color : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = InputSanitizer.clean(_titleController.text);
    final valueText = _valueController.text.replaceAll(',', '.'); 
    final value = double.tryParse(valueText);

    if (title.isNotEmpty && value != null && value > 0) {
      final controller = context.read<FinanceController>();
      
      controller.addTransaction(
        title: title, 
        value: value, 
        isIncome: _isIncome, 
        date: _selectedDate
      );
      
      Navigator.pop(context);
    }
  }
}