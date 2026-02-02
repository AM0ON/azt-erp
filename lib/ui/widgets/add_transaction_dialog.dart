import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/task_controller.dart'; // Para checar permissão
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
  String? _selectedCategory; // [NOVO]

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeController = context.watch<FinanceController>();
    final isCTO = context.read<TaskController>().isManager; // Permissão

    // Define qual lista mostrar baseada no tipo (Receita/Despesa)
    final currentCategories = _isIncome 
        ? financeController.incomeCategories 
        : financeController.expenseCategories;

    // Garante que a categoria selecionada ainda é válida ao trocar de aba
    if (_selectedCategory == null || !currentCategories.contains(_selectedCategory)) {
      _selectedCategory = currentCategories.first;
    }

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

            // SELETOR TIPO
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: "Receita", 
                    isSelected: _isIncome, 
                    color: const Color(0xFF2EA063),
                    onTap: () => setState(() => _isIncome = true)
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    label: "Despesa", 
                    isSelected: !_isIncome, 
                    color: Colors.redAccent,
                    onTap: () => setState(() => _isIncome = false)
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CAMPOS TEXTO
            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: _inputDecoration("Descrição", Icons.description),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: _inputDecoration("Valor (R\$)", Icons.attach_money),
                  ),
                ),
                const SizedBox(width: 12),
                
                // SELETOR DATA
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
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
            const SizedBox(height: 16),

            // [NOVO] SELETOR DE CATEGORIA + BOTÃO ADICIONAR
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: GoogleFonts.inter(color: Colors.white),
                        isExpanded: true,
                        items: currentCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                if (isCTO) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.white10),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    tooltip: "Nova Categoria",
                    onPressed: () => _showAddCategoryDialog(context, financeController),
                  )
                ]
              ],
            ),

            const SizedBox(height: 32),

            // BOTÕES AÇÃO
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

  // Helpers Visuais
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildTypeButton({required String label, required bool isSelected, required Color color, required VoidCallback onTap}) {
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
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, 
      initialDate: _selectedDate, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
         data: Theme.of(context).copyWith(
           colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface)
         ), 
         child: child!
       )
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  // [NOVO] Dialog para criar categoria na hora
  void _showAddCategoryDialog(BuildContext context, FinanceController controller) {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Nova Categoria de ${_isIncome ? 'Receita' : 'Despesa'}", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: catController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nome da categoria...",
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.black26,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          FilledButton(
            child: const Text("Adicionar"),
            onPressed: () {
              if (catController.text.isNotEmpty) {
                controller.addCategory(catController.text, _isIncome);
                Navigator.pop(ctx);
              }
            },
          )
        ],
      ),
    );
  }

  void _submit() {
    final title = InputSanitizer.clean(_titleController.text);
    final valueText = _valueController.text.replaceAll(',', '.'); 
    final value = double.tryParse(valueText);

    if (title.isNotEmpty && value != null && value > 0 && _selectedCategory != null) {
      context.read<FinanceController>().addTransaction(
        title: title, 
        value: value, 
        isIncome: _isIncome, 
        date: _selectedDate,
        category: _selectedCategory! // [NOVO] Passando a categoria
      );
      Navigator.pop(context);
    }
  }
}