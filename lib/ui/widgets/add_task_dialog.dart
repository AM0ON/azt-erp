import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? taskToEdit;
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
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _assigneeController.text = t.assignee ?? "";
      _selectedPriority = t.priority.name;
      _selectedCategory = t.category.toString().split('.').last; 
      if (_selectedCategory == 'azorTechProducao') _selectedCategory = 'azorTechProducao'; 
      _selectedDate = t.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    
    // As cores vêm do DialogTheme no main.dart (Fundo escuro)
    return Dialog(
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
                Text(isEditing ? "Editar Tarefa" : "Nova Tarefa", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            // TextFields automagicamente escuros via main.dart
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Título")),
            const SizedBox(height: 16),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Descrição"), maxLines: 2),
            const SizedBox(height: 16),
            TextField(controller: _assigneeController, decoration: const InputDecoration(labelText: "Responsável", prefixIcon: Icon(Icons.person))),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    dropdownColor: Theme.of(context).cardTheme.color, // Dropdown escuro
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
                    dropdownColor: Theme.of(context).cardTheme.color,
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
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2020), 
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(data: Theme.of(context), child: child!); // Força tema dark no datepicker
                  }
                );
                if(date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Data de Entrega", prefixIcon: Icon(Icons.calendar_today)),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (_titleController.text.isEmpty) return;
                  Navigator.pop(context, {
                    'title': _titleController.text, 'desc': _descController.text, 'assignee': _assigneeController.text,
                    'priority': _selectedPriority, 'category': _selectedCategory, 'date': _selectedDate
                  });
                },
                icon: Icon(isEditing ? Icons.save : Icons.check, size: 18),
                label: Text(isEditing ? "Salvar" : "Criar"),
              ),
            )
          ],
        ),
      ),
    );
  }
}