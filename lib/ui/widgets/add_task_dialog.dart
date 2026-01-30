import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? taskToEdit;
  const AddTaskDialog({super.key, this.taskToEdit});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _clientController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _newSubtaskController = TextEditingController();
  final List<String> _tempSubtasks = [];

  String _selectedPriority = 'media';
  String _selectedCategory = 'Pessoal'; 
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _clientController.text = t.client ?? "";
      _assigneeController.text = t.assignee ?? "";
      _selectedPriority = t.priority.name;
      _selectedCategory = t.category; // Já é String
      _selectedDate = t.dueDate;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categories = context.read<TaskController>().categories;
        if (categories.length > 1) { 
           setState(() {
             _selectedCategory = categories[1].label; // Pega o primeiro após 'Todas'
           });
        }
      });
    }
  }

  void _addSubtaskItem() {
    if (_newSubtaskController.text.trim().isNotEmpty) {
      setState(() {
        _tempSubtasks.add(_newSubtaskController.text.trim());
        _newSubtaskController.clear();
      });
    }
  }

  void _removeSubtaskItem(int index) {
    setState(() {
      _tempSubtasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final isManager = controller.isManager;
    final isEditing = widget.taskToEdit != null;
    final currentUser = controller.currentUserName;
    final isAssignedToMe = _assigneeController.text == currentUser;

    // Remove 'Todas' da lista de escolha
    final categoryItems = controller.categories
        .where((c) => c.label != 'Todas')
        .map((c) => DropdownMenuItem(value: c.label, child: Text(c.label)))
        .toList();

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
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
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Título")),
              const SizedBox(height: 16),
              TextField(controller: _clientController, decoration: const InputDecoration(labelText: "Cliente", prefixIcon: Icon(Icons.business))),
              const SizedBox(height: 16),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: "Descrição"), maxLines: 2),
              const SizedBox(height: 16),
              Row(children: [
                  Expanded(child: TextField(controller: _assigneeController, enabled: isManager, decoration: InputDecoration(labelText: "Responsável", prefixIcon: const Icon(Icons.person), filled: !isManager, fillColor: !isManager ? Colors.black26 : const Color(0xFF1F2937)))),
                  if (!isManager) ...[const SizedBox(width: 8), TextButton.icon(onPressed: () => setState(() => _assigneeController.text = isAssignedToMe ? "" : currentUser), icon: Icon(isAssignedToMe ? Icons.close : Icons.back_hand, color: isAssignedToMe ? Colors.redAccent : Colors.blueAccent), label: Text(isAssignedToMe ? "Soltar" : "Pegar"))]
              ]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      dropdownColor: Theme.of(context).cardTheme.color,
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
                      // Garante que o valor selecionado existe na lista, senão pega o primeiro disponível
                      value: categoryItems.any((i) => i.value == _selectedCategory) ? _selectedCategory : (categoryItems.isNotEmpty ? categoryItems.first.value : null),
                      dropdownColor: Theme.of(context).cardTheme.color,
                      decoration: const InputDecoration(labelText: "Categoria"),
                      items: categoryItems,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
                    builder: (context, child) => Theme(data: Theme.of(context), child: child!)
                  );
                  if(date != null) setState(() => _selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Data de Entrega", prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              Text("Checklist Inicial", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _newSubtaskController, decoration: const InputDecoration(hintText: "Adicionar etapa...", isDense: true), onSubmitted: (_) => _addSubtaskItem())),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _addSubtaskItem, icon: const Icon(Icons.add), style: IconButton.styleFrom(backgroundColor: const Color(0xFF2EA063)))
                ],
              ),
              const SizedBox(height: 8),
              if (_tempSubtasks.isNotEmpty)
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: _tempSubtasks.asMap().entries.map((entry) => ListTile(dense: true, leading: const Icon(Icons.check_box_outline_blank, size: 18, color: Colors.grey), title: Text(entry.value, style: GoogleFonts.inter(fontSize: 13)), trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.redAccent), onPressed: () => _removeSubtaskItem(entry.key)))).toList()),
                ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    if (_titleController.text.isEmpty) return;
                    Navigator.pop(context, {
                      'title': _titleController.text, 'desc': _descController.text, 'client': _clientController.text, 'assignee': _assigneeController.text,
                      'priority': _selectedPriority, 'category': _selectedCategory, 'date': _selectedDate, 'subtasks': _tempSubtasks,
                    });
                  },
                  icon: Icon(isEditing ? Icons.save : Icons.check, size: 18),
                  label: Text(isEditing ? "Salvar" : "Criar"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}