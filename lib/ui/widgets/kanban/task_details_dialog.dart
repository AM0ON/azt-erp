import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/task_model.dart';
import '../../../controllers/task_controller.dart';
import '../../../core/app_colors.dart';

class TaskDetailsDialog extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsDialog({super.key, required this.task});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final TextEditingController _subTaskController = TextEditingController();

  @override
  void dispose() {
    _subTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o controller para atualizar a tela quando houver mudanças (ex: check na subtarefa)
    final controller = context.watch<TaskController>();
    
    // Tenta encontrar a tarefa atualizada na lista. Se não achar (foi deletada?), usa a do widget.
    TaskModel task;
    try {
      task = controller.tasks.firstWhere((t) => t.id == widget.task.id);
    } catch (e) {
      task = widget.task;
    }

    final dateStr = task.deadline != null 
        ? DateFormat('dd/MM/yyyy').format(task.deadline!) 
        : 'Sem Prazo';

    // Busca o ícone da categoria
    final categoryItem = controller.categories.firstWhere(
      (c) => c.label == task.category,
      orElse: () => controller.categories.first
    );

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COLUNA ESQUERDA (Detalhes e Subtarefas) ---
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER: Prioridade, Categoria, Status
                    Row(
                      children: [
                        // Badge Prioridade
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.priorityColor.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            task.priorityLabel.toUpperCase(), 
                            style: GoogleFonts.inter(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              color: task.priorityColor
                            )
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Badge Categoria
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700), 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(categoryItem.icon, size: 10, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                task.category.toUpperCase(),
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Dropdown Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskStatus>(
                              value: task.status,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              dropdownColor: AppColors.surface,
                              items: TaskStatus.values.map((s) {
                                // Formata o texto do Enum (ex: TaskStatus.todo -> A Fazer)
                                String label;
                                switch(s) {
                                  case TaskStatus.todo: label = "A Fazer"; break;
                                  case TaskStatus.inProgress: label = "Em Progresso"; break;
                                  case TaskStatus.done: label = "Concluído"; break;
                                }
                                return DropdownMenuItem(value: s, child: Text(label));
                              }).toList(),
                              onChanged: (val) { 
                                if (val != null) controller.updateTaskStatus(task.id, val); 
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // TÍTULO E DESCRIÇÃO
                    Text(task.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    Text("Descrição", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.description.isEmpty ? "Sem descrição detalhada." : task.description, 
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade300, height: 1.5)
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // --- SUBTAREFAS (CHECKLIST) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Text("Checklist", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(
                          "${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}", 
                          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey)
                        ),
                      ]
                    ),
                    const SizedBox(height: 12),
                    
                    // Input Nova Subtarefa
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subTaskController, 
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Adicionar item...", 
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(borderSide: BorderSide.none)
                            ), 
                            onSubmitted: (val) { 
                              if(val.isNotEmpty) { 
                                controller.addSubTask(task.id, val); 
                                _subTaskController.clear(); 
                              } 
                            }
                          )
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle), 
                          color: AppColors.primary, 
                          onPressed: () { 
                            if(_subTaskController.text.isNotEmpty) { 
                              controller.addSubTask(task.id, _subTaskController.text); 
                              _subTaskController.clear(); 
                            } 
                          }
                        )
                      ]
                    ),
                    const SizedBox(height: 12),
                    
                    // Lista de Subtarefas
                    ...task.subtasks.map((sub) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black12, 
                        borderRadius: BorderRadius.circular(8), 
                        border: Border.all(color: Colors.white10)
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Checkbox(
                          value: sub.isCompleted, 
                          activeColor: AppColors.primary, 
                          side: const BorderSide(color: Colors.grey),
                          onChanged: (val) => controller.toggleSubTask(task.id, sub.id)
                        ),
                        title: Text(
                          sub.title, 
                          style: GoogleFonts.inter(
                            decoration: sub.isCompleted ? TextDecoration.lineThrough : null, 
                            color: sub.isCompleted ? Colors.grey : Colors.white
                          )
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey), 
                          onPressed: () => controller.removeSubTask(task.id, sub.id)
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            // Divisor Vertical
            Container(width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 32)),
            
            // --- COLUNA DIREITA (Meta Dados) ---
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.calendar_today, "Entrega", dateStr),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    Icons.person, 
                    "Responsável", 
                    task.assignedTo.isEmpty ? "Não atribuído" : task.assignedTo.join(", ")
                  ),
                  
                  const Spacer(),
                  
                  // Botão de Fechar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white10),
                        padding: const EdgeInsets.symmetric(vertical: 16)
                      ),
                      child: const Text("Fechar", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey), 
        const SizedBox(width: 12), 
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)), 
              Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis)
            ]
          ),
        )
      ]
    );
  }
}