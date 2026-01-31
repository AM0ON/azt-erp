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
      _selectedCategory = t.category;
      _selectedDate = t.dueDate;
      // Carrega subtasks existentes (apenas títulos para edição simplificada)
      _tempSubtasks.addAll(t.subtasks.map((s) => s.title));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          final cats = context.read<TaskController>().categories;
          if(cats.length > 1) setState(() => _selectedCategory = cats[1].label);
        }
      });
    }
  }

  void _addSubtaskItem() {
    if (_newSubtaskController.text.trim().isNotEmpty) {
      setState(() { _tempSubtasks.add(_newSubtaskController.text.trim()); _newSubtaskController.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final isManager = controller.isManager; // Verifica se é gestor
    final isEditing = widget.taskToEdit != null;
    
    // Categorias disponíveis
    final categoryItems = controller.categories
        .where((c) => c.label != 'Todas')
        .map((c) => DropdownMenuItem(value: c.label, child: Text(c.label)))
        .toList();

    return Dialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? "Editar Tarefa" : "Nova Tarefa", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey))
                ],
              ),
              const SizedBox(height: 24),
              
              // Título e Cliente
              _buildInput("Título", _titleController, autoFocus: true),
              const SizedBox(height: 16),
              
              // Linha: Cliente e Responsável
              Row(children: [
                Expanded(child: _buildInput("Cliente", _clientController, icon: Icons.business)),
                const SizedBox(width: 16),
                
                // LÓGICA DE ATRIBUIÇÃO
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      _buildInput(
                        "Responsável", 
                        _assigneeController, 
                        icon: Icons.person, 
                        enabled: isManager // Só gestor digita livremente
                      ),
                      if (!isManager) // Se não é gestor, mostra botão para pegar a tarefa
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                            onPressed: () => setState(() => _assigneeController.text = controller.currentUserName),
                            child: Text("Pegar", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2EA063))),
                          ),
                        )
                    ],
                  ),
                ),
              ]),
              
              const SizedBox(height: 16),
              _buildInput("Descrição", _descController, maxLines: 3),
              const SizedBox(height: 24),
              
              // Prioridade e Categoria (Gestor pode alterar livremente)
              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Prioridade", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        dropdownColor: const Color(0xFF111827),
                        decoration: _inputDeco(null),
                        items: const [DropdownMenuItem(value: 'baixa', child: Text("Baixa")), DropdownMenuItem(value: 'media', child: Text("Média")), DropdownMenuItem(value: 'alta', child: Text("Alta")), DropdownMenuItem(value: 'urgente', child: Text("Urgente"))],
                        onChanged: (v) => setState(() => _selectedPriority = v!),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Categoria", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: categoryItems.any((c) => c.value == _selectedCategory) ? _selectedCategory : null,
                        dropdownColor: const Color(0xFF111827),
                        decoration: _inputDeco(null),
                        items: categoryItems,
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ]),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              // Data
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030), builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF2EA063))), child: child!));
                  if(d != null) setState(() => _selectedDate = d);
                },
                child: InputDecorator(decoration: _inputDeco("Data de Entrega", icon: Icons.calendar_today), child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white))),
              ),
              
              const SizedBox(height: 32),
              // Checklist
              Text("Checklist", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _buildInput("Adicionar etapa...", _newSubtaskController, onSubmitted: (_) => _addSubtaskItem())),
                const SizedBox(width: 8),
                Container(decoration: const BoxDecoration(color: Color(0xFF2EA063), shape: BoxShape.circle), child: IconButton(onPressed: _addSubtaskItem, icon: const Icon(Icons.add, color: Colors.white)))
              ]),
              if (_tempSubtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: _tempSubtasks.asMap().entries.map((e) => ListTile(dense: true, title: Text(e.value, style: const TextStyle(color: Colors.white70)), trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.red), onPressed: () => setState(() => _tempSubtasks.removeAt(e.key))))).toList()),
                )
              ],

              const SizedBox(height: 40),
              // Ações Finais
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2EA063), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  onPressed: () {
                    if (_titleController.text.isEmpty) return;
                    Navigator.pop(context, {
                      'title': _titleController.text, 'desc': _descController.text, 'client': _clientController.text, 'assignee': _assigneeController.text,
                      'priority': _selectedPriority, 'category': _selectedCategory, 'date': _selectedDate, 'subtasks': _tempSubtasks
                    });
                  },
                  icon: const Icon(Icons.check), label: const Text("Salvar")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController c, {bool enabled = true, IconData? icon, int maxLines = 1, Function(String)? onSubmitted, bool autoFocus = false}) {
    return TextField(
      controller: c, enabled: enabled, maxLines: maxLines, onSubmitted: onSubmitted, autofocus: autoFocus,
      style: GoogleFonts.inter(color: enabled ? Colors.white : Colors.grey),
      decoration: _inputDeco(label, icon: icon)
    );
  }

  InputDecoration _inputDeco(String? label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
      filled: true,
      fillColor: const Color(0xFF111827),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      labelStyle: TextStyle(color: Colors.grey[500]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
    );
  }
}