import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'add_task_dialog.dart';
import 'task_details_dialog.dart'; // Importe o novo dialog

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM', 'pt_BR').format(task.dueDate);
    final priorityColor = task.priorityTextColor; 
    final assigneeInitials = (task.assignee != null && task.assignee!.isNotEmpty) 
        ? task.assignee!.substring(0, 1).toUpperCase() 
        : "?";

    return InkWell(
      // AQUI: Clique no card abre os detalhes
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskDetailsDialog(task: task),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: task.isCompleted ? Colors.grey.shade300 : priorityColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniBadge(task.categoryLabel, task.categoryIcon),
                            
                            // Menu de Opções Rápido (3 pontinhos)
                            SizedBox(
                              height: 24, width: 24,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.more_horiz, size: 18, color: Colors.grey.shade400),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    context.read<TaskController>().deleteTask(task.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text("Excluir", style: TextStyle(color: Colors.red))]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: onToggle, // Checkbox funciona independente do card
                              child: Container(
                                margin: const EdgeInsets.only(top: 2, right: 8),
                                width: 18, height: 18,
                                decoration: BoxDecoration(
                                  border: Border.all(color: task.isCompleted ? priorityColor : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                  color: task.isCompleted ? priorityColor : Colors.transparent
                                ),
                                child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color: task.isCompleted ? Colors.grey.shade400 : const Color(0xFF111827),
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            if (task.assignee != null && task.assignee!.isNotEmpty)
                              Container(
                                width: 22, height: 22,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(assigneeInitials, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                              ),

                            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(dateStr, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey.shade500)),
                            
                            const Spacer(),
                            
                            if (!task.isCompleted)
                              Text(
                                task.priorityLabel.toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: priorityColor, fontWeight: FontWeight.bold),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}