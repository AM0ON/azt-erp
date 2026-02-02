import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Imports da Estrutura
import '../../../core/app_colors.dart';
import '../../../models/task_model.dart';
import '../../../controllers/task_controller.dart';
import '../../../controllers/client_controller.dart'; 

class AddTaskDialog extends StatefulWidget {
  final TaskModel? taskToEdit;
  
  const AddTaskDialog({super.key, this.taskToEdit});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  // Controladores de Texto
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _clientController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _newSubtaskController = TextEditingController();
  
  // Estado Local
  final List<String> _tempSubtasks = [];
  String _selectedPriority = 'media';
  String _selectedCategory = 'Pessoal'; 
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos com os dados existentes
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _clientController.text = t.client ?? "";
      _assigneeController.text = t.assignee ?? "";
      _selectedPriority = t.priority.name;
      _selectedCategory = t.category;
      _selectedDate = t.dueDate;
      _tempSubtasks.addAll(t.subtasks.map((s) => s.title));
    } else {
      // Se for nova tarefa, tenta pegar a segunda categoria como padrão (ex: Projetos)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          final cats = context.read<TaskController>().categories;
          if(cats.length > 1) {
            setState(() => _selectedCategory = cats[1].label);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _clientController.dispose();
    _assigneeController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _addSubtaskItem() {
    if (_newSubtaskController.text.trim().isNotEmpty) {
      setState(() {
        _tempSubtasks.add(_newSubtaskController.text.trim());
        _newSubtaskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final clientController = context.watch<ClientController>();
    final isManager = controller.isManager;
    
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 550, // Largura fixa para ficar bonito no Desktop/Tablet
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TÍTULO DO DIALOG ---
              Text(
                widget.taskToEdit != null ? "Editar Tarefa" : "Nova Tarefa", 
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 24),
              
              // --- CAMPO: TÍTULO ---
              _buildInput("Título", _titleController, autoFocus: true),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CAMPO: CLIENTE (AUTOCOMPLETE) ---
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<String>(
                          initialValue: TextEditingValue(text: _clientController.text),
                          
                          // Lógica de filtro: Busca na lista do ClientController
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text == '') return const Iterable<String>.empty();
                            return clientController.clients.where((option) => 
                              option.toLowerCase().contains(textEditingValue.text.toLowerCase())
                            );
                          },
                          
                          onSelected: (selection) => _clientController.text = selection,
                          
                          // O Campo de Texto em si
                          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                            // Sincroniza o controller interno do Autocomplete com o nosso
                            textController.addListener(() { _clientController.text = textController.text; });
                            // Se viemos de uma edição, popula o texto inicial
                            if (_clientController.text.isNotEmpty && textController.text.isEmpty) {
                              textController.text = _clientController.text;
                            }
                            
                            return TextField(
                              controller: textController, 
                              focusNode: focusNode, 
                              style: GoogleFonts.inter(color: Colors.white), 
                              decoration: _inputDeco("Cliente", icon: Icons.business)
                            );
                          },
                          
                          // A Lista de Sugestões (Dropdown)
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft, 
                              child: Material(
                                color: AppColors.surface, 
                                elevation: 4, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Container(
                                  width: constraints.maxWidth, 
                                  constraints: const BoxConstraints(maxHeight: 200), 
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero, 
                                    itemCount: options.length, 
                                    itemBuilder: (ctx, i) => InkWell(
                                      onTap: () => onSelected(options.elementAt(i)), 
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0), 
                                        child: Text(options.elementAt(i), style: const TextStyle(color: Colors.white))
                                      )
                                    )
                                  )
                                )
                              )
                            );
                          },
                        );
                      }
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // --- CAMPO: RESPONSÁVEL ---
                  Expanded(
                    child: _buildInput("Responsável", _assigneeController, icon: Icons.person, enabled: isManager)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // --- CAMPO: DESCRIÇÃO ---
              _buildInput("Descrição", _descController, maxLines: 3),
              const SizedBox(height: 24),
              
              // --- LINHA: PRIORIDADE E DATA ---
              Row(
                children: [
                   // Dropdown de Prioridade
                   Expanded(
                     child: DropdownButtonFormField<String>(
                       value: _selectedPriority, 
                       dropdownColor: AppColors.background, 
                       style: GoogleFonts.inter(color: Colors.white),
                       decoration: _inputDeco("Prioridade"), 
                       items: const [
                         DropdownMenuItem(value: 'baixa', child: Text("Baixa")), 
                         DropdownMenuItem(value: 'media', child: Text("Média")), 
                         DropdownMenuItem(value: 'alta', child: Text("Alta")), 
                         DropdownMenuItem(value: 'urgente', child: Text("Urgente"))
                       ], 
                       onChanged: (v) => setState(() => _selectedPriority = v!)
                     )
                   ),
                   const SizedBox(width: 16),
                   
                   // Seletor de Data
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
                         if(d != null) setState(() => _selectedDate = d); 
                       }, 
                       child: InputDecorator(
                         decoration: _inputDeco("Data Entrega", icon: Icons.calendar_today), 
                         child: Text(
                           DateFormat('dd/MM/yyyy').format(_selectedDate), 
                           style: const TextStyle(color: Colors.white)
                         )
                       )
                     ),
                   ),
                ],
              ),

              const SizedBox(height: 32),
              
              // --- CHECKLIST / SUBTAREFAS ---
              Text("Checklist", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInput("Nova etapa...", _newSubtaskController, onSubmitted: (_) => _addSubtaskItem())
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSubtaskItem, 
                    icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30)
                  )
                ]
              ),
              
              // Lista visual das sub-tarefas
              if (_tempSubtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: _tempSubtasks.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String val = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          dense: true,
                          title: Text(val, style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 16),
                            onPressed: () => setState(() => _tempSubtasks.removeAt(idx)),
                          ),
                        ),
                      );
                    }).toList()
                  ),
                ),

              const SizedBox(height: 40),
              
              // --- BOTÃO SALVAR ---
              Align(
                alignment: Alignment.centerRight, 
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ), 
                  onPressed: () { 
                    if (_titleController.text.isEmpty) return; 
                    
                    // Retorna um Map com os dados para a TaskPage processar
                    Navigator.pop(context, {
                      'title': _titleController.text, 
                      'desc': _descController.text, 
                      'client': _clientController.text, 
                      'assignee': _assigneeController.text, 
                      'priority': _selectedPriority, 
                      'category': _selectedCategory, 
                      'date': _selectedDate, 
                      'subtasks': _tempSubtasks
                    }); 
                  }, 
                  icon: const Icon(Icons.check), 
                  label: const Text("Salvar Tarefa")
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES DE UI ---
  
  Widget _buildInput(String label, TextEditingController c, {bool enabled = true, IconData? icon, int maxLines = 1, Function(String)? onSubmitted, bool autoFocus = false}) {
    return TextField(
      controller: c, 
      enabled: enabled, 
      maxLines: maxLines, 
      onSubmitted: onSubmitted, 
      autofocus: autoFocus, 
      style: GoogleFonts.inter(color: enabled ? Colors.white : Colors.grey), 
      decoration: _inputDeco(label, icon: icon)
    );
  }

  InputDecoration _inputDeco(String? label, {IconData? icon}) {
    return InputDecoration(
      labelText: label, 
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null, 
      filled: true, 
      fillColor: AppColors.background, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), 
        borderSide: BorderSide.none
      ), 
      labelStyle: TextStyle(color: Colors.grey[500])
    );
  }
}