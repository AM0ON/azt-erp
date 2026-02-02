import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import '../../../controllers/client_controller.dart'; // Se usar clientes

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _deadline;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Seleciona a primeira categoria por padrão para não ir nulo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TaskController>();
      if (controller.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = controller.categories.first.label;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Acesso aos Controllers
    final taskController = context.watch<TaskController>();
    
    // Lista de Strings para o Dropdown (Extraindo dos objetos CategoryItem)
    final categoryLabels = taskController.categories.map((e) => e.label).toList();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nova Tarefa", 
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 24),
          
              // Título
              TextField(
                controller: _titleController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: _inputDecoration("Título da Tarefa", Icons.task_alt),
              ),
              const SizedBox(height: 16),
          
              // Descrição
              TextField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: _inputDecoration("Descrição / Detalhes", Icons.description_outlined),
              ),
              const SizedBox(height: 24),
          
              // Linha: Prioridade + Categoria
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Prioridade", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskPriority>(
                              value: _priority,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              style: GoogleFonts.inter(color: Colors.white),
                              items: TaskPriority.values.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Text(p.toString().split('.').last.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _priority = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // SELETOR DE CATEGORIA (Obrigatório agora)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Categoria", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              style: GoogleFonts.inter(color: Colors.white),
                              items: categoryLabels.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 16),
          
              // Data de Entrega
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10)
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _deadline == null 
                          ? "Definir Prazo (Opcional)" 
                          : DateFormat("dd 'de' MMMM", 'pt_BR').format(_deadline!),
                        style: GoogleFonts.inter(color: _deadline == null ? Colors.grey : Colors.white),
                      ),
                      const Spacer(),
                      if (_deadline != null)
                        InkWell(
                          onTap: () => setState(() => _deadline = null),
                          child: const Icon(Icons.close, size: 16, color: Colors.grey),
                        )
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 32),
          
              // Botões
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
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_titleController.text.isNotEmpty && _selectedCategory != null) {
                        // CHAMADA ATUALIZADA DO CONTROLLER
                        taskController.addTask(
                          title: _titleController.text,
                          description: _descController.text,
                          priority: _priority,
                          category: _selectedCategory!, // Passando a categoria
                          deadline: _deadline,
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Criar Tarefa"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
         data: Theme.of(context).copyWith(
           colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface)
         ), 
         child: child!
       )
    );
    if (d != null) setState(() => _deadline = d);
  }
}