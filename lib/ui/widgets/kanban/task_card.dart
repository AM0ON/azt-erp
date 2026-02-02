import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
// Certifique-se de importar o TaskDetailsDialog se ele estiver em outro arquivo
// import 'task_details_dialog.dart'; 

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    
    // [CORREÇÃO 1]: Não chame deleteTask aqui! Verifique a permissão.
    final canDelete = controller.isManager; 
    
    // Lógica da Categoria
    final categoryItem = controller.categories.firstWhere(
      (c) => c.label == task.category,
      orElse: () => controller.categories.first
    );

    // [CORREÇÃO 2]: Tratamento de Data (deadline pode ser nulo no Model)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    // Se não tiver prazo, usa data atual apenas para não quebrar, mas vamos esconder
    final taskDeadline = task.deadline; 
    final taskDate = taskDeadline != null 
        ? DateTime(taskDeadline.year, taskDeadline.month, taskDeadline.day) 
        : null;
    
    // [CORREÇÃO 3]: Uso de Enums (TaskStatus) em vez de booleans (isCompleted)
    final isDone = task.status == TaskStatus.done;

    Color dateColor = Colors.grey[500]!;
    
    if (!isDone && taskDate != null) {
      if (taskDate.isBefore(today)) {
        dateColor = Colors.redAccent; // Atrasado
      } else if (taskDate.isAtSameMomentAs(today)) {
        dateColor = Colors.orangeAccent; // Hoje
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        dateColor = const Color(0xFFEAB308); // Amanhã
      }
    }
    
    final dateStr = taskDeadline != null 
        ? DateFormat('dd MMM', 'pt_BR').format(taskDeadline).toUpperCase()
        : 'SEM PRAZO';

    return InkWell(
      onTap: () {
        // Exemplo: showDialog(context: context, builder: (_) => TaskDetailsDialog(task: task));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: Colors.white10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // --- TOPO: CATEGORIA E MENU ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  _tag(categoryItem.label, categoryItem.icon, Colors.grey),
                  
                  if(canDelete) 
                    InkWell(
                      onTap: () => controller.deleteTask(task.id), // A ação acontece SÓ no clique
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.grey) // Mudei ícone para lixeira
                    )
                ]
              ),
              
              const SizedBox(height: 12),
              
              // --- MEIO: CHECKBOX E TÍTULO ---
              Row(
                children: [
                  InkWell(
                    onTap: () {
                       // Lógica de Toggle
                       final newStatus = isDone ? TaskStatus.todo : TaskStatus.done;
                       controller.updateTaskStatus(task.id, newStatus);
                    }, 
                    child: Icon(
                      isDone ? Icons.check_circle : Icons.circle_outlined, 
                      color: isDone ? AppColors.primary : Colors.grey, 
                      size: 24
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title, 
                      style: GoogleFonts.inter(
                        color: Colors.white, 
                        fontWeight: FontWeight.w500,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey
                      )
                    )
                  ),
                ]
              ),
              
              const SizedBox(height: 12),
              
              // --- RODAPÉ: DATA ---
              if (taskDeadline != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: dateColor), 
                    const SizedBox(width: 6), 
                    Text(dateStr, style: TextStyle(color: dateColor, fontSize: 11, fontWeight: FontWeight.bold))
                  ]
                )
            ]
          ),
        ),
      ),
    );
  }

  // Helper Widget para a Tag
  Widget _tag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}