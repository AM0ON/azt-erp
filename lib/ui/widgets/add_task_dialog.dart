import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? taskToEdit; // Parâmetro restaurado para edição

  const AddTaskDialog({super.key, this.taskToEdit});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _assigneeController = TextEditingController();
  
  String _selectedPriority = 'media';
  String _selectedCategory = 'pessoal'; 
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Se veio uma tarefa para editar, preenchemos os campos
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _assigneeController.text = t.assignee ?? "";
      _selectedPriority = t.priority.name;
      // Convertendo o Enum para String para o Dropdown
      _selectedCategory = t.category.toString().split('.').last; 
      // Mapeamento manual para casos onde o nome do enum difere do valor esperado no dropdown (ex: azorTechProducao)
      if (_selectedCategory == 'azorTechProducao') _selectedCategory = 'azorTechProducao'; // Mantém igual pois o value do dropdown espera isso
      
      _selectedDate = t.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "Editar Tarefa" : "Nova Tarefa", 
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 32),
            
            // Título
            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(labelText: "Título da Tarefa"),
            ),
            const SizedBox(height: 16),
            
            // Descrição
            TextField(
              controller: _descController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(labelText: "Descrição"),
              maxLines: 2,
            ),
             const SizedBox(height: 16),
            
            // Responsável
            TextField(
              controller: _assigneeController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Responsável (Nome)",
                prefixIcon: Icon(Icons.person_outline, size: 18)
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    decoration: const InputDecoration(labelText: "Prioridade"),
                    items: const [
                      DropdownMenuItem(value: 'baixa', child: Text("Baixa")),
                      DropdownMenuItem(value: 'media', child: Text("Média")),
                      DropdownMenuItem(value: 'alta', child: Text("Alta")),
                      DropdownMenuItem(value: 'urgente', child: Text("Urgente")),
                    ],
                    onChanged: (v) => setState(() => _selectedPriority = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    decoration: const InputDecoration(labelText: "Categoria"),
                    items: const [
                      DropdownMenuItem(value: 'pessoal', child: Text("Pessoal")),
                      DropdownMenuItem(value: 'azorTechProducao', child: Text("Produção")),
                      DropdownMenuItem(value: 'azorTechWeb', child: Text("Web Dev")),
                      DropdownMenuItem(value: 'financeiro', child: Text("Financeiro")),
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Seletor de Data Simples
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2020), 
                  lastDate: DateTime(2030)
                );
                if(date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Data de Entrega",
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // Botão Salvar
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (_titleController.text.isEmpty) return;
                  
                  // Retorna um Map com os dados
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'desc': _descController.text,
                    'assignee': _assigneeController.text,
                    'priority': _selectedPriority,
                    'category': _selectedCategory,
                    'date': _selectedDate
                  });
                },
                icon: Icon(isEditing ? Icons.save : Icons.check, size: 18),
                label: Text(isEditing ? "Salvar Alterações" : "Criar Tarefa"),
              ),
            )
          ],
        ),
      ),
    );
  }
}