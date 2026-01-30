import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'task_details_dialog.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM', 'pt_BR').format(task.dueDate);
    final priorityColor = task.priorityTextColor; 
    
    // Cores obtidas do Tema Global para consistência
    final cardColor = Theme.of(context).cardTheme.color;
    final borderColor = Theme.of(context).dividerTheme.color;

    return InkWell(
      onTap: () => showDialog(context: context, builder: (_) => TaskDetailsDialog(task: task)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor, // SURFACE COLOR (ESCURO)
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: task.isCompleted ? Colors.grey.shade800 : priorityColor),
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
                            Icon(Icons.more_horiz, size: 18, color: Colors.grey[500]), // Ícone cinza
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: onToggle,
                              child: Container(
                                margin: const EdgeInsets.only(top: 2, right: 10),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(color: task.isCompleted ? priorityColor : Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(6),
                                  color: task.isCompleted ? priorityColor : Colors.transparent
                                ),
                                child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                  color: task.isCompleted ? Colors.grey.shade600 : Colors.white, // Texto Branco
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
                            if (task.assignee != null)
                              Container(
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(color: Color(0xFF374151), shape: BoxShape.circle),
                                child: Text(task.assignee![0], style: const TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(dateStr, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
                            const Spacer(),
                            Text(task.priorityLabel.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: priorityColor, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Fundo ainda mais escuro para o badge
        borderRadius: BorderRadius.circular(4), 
        border: Border.all(color: const Color(0xFF374151))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey[400])),
        ],
      ),
    );
  }
}