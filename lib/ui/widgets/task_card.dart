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
    final controller = context.read<TaskController>();
    
    // Cores e Permissões
    final priorityColor = task.priorityTextColor; 
    final cardColor = Theme.of(context).cardTheme.color;
    final bool canDelete = controller.canCreateOrDelete;
    final bool canComplete = controller.canComplete(task);

    // Data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    Color dateColor = Colors.grey[500]!;
    if (!task.isCompleted) {
      if (taskDate.isBefore(today)) {
        dateColor = Colors.redAccent; 
      } else if (taskDate.isAtSameMomentAs(today)) {
        dateColor = Colors.orangeAccent;
      }
    }
    
    final dateStr = DateFormat('dd/MM', 'pt_BR').format(task.dueDate);

    // Progresso
    final totalSub = task.subtasks.length;
    final completedSub = task.subtasks.where((s) => s.isCompleted).length;
    final double progress = totalSub > 0 ? completedSub / totalSub : 0.0;

    return InkWell(
      onTap: () => showDialog(context: context, builder: (_) => TaskDetailsDialog(task: task)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          // Borda Reforçada
          border: Border.all(
            color: task.isCompleted ? Colors.grey.shade800 : priorityColor.withOpacity(0.5), 
            width: 1.5 
          ),
          boxShadow: [
             if (!task.isCompleted && task.priority == TaskPriority.urgente)
               BoxShadow(color: priorityColor.withOpacity(0.15), blurRadius: 8, spreadRadius: 0)
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: task.isCompleted ? Colors.grey.shade800 : priorityColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Row(children: [
                                Flexible(child: _buildMiniBadge(task.categoryLabel, task.categoryIcon)),
                                if (task.client != null && task.client!.isNotEmpty) ...[
                                  const SizedBox(width: 8), 
                                  Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.business, size: 10, color: Colors.blueAccent), const SizedBox(width: 4), Flexible(child: Text(task.client!.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueAccent), overflow: TextOverflow.ellipsis))])) )
                                ]
                            ])),
                            if (canDelete) SizedBox(height: 24, width: 24, child: PopupMenuButton<String>(padding: EdgeInsets.zero, icon: Icon(Icons.more_horiz, size: 18, color: Colors.grey[500]), onSelected: (value) { if (value == 'delete') controller.deleteTask(task.id); }, itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text("Excluir", style: TextStyle(color: Colors.redAccent))]))]))
                          ],
                        ),
                        const SizedBox(height: 10),
                        // BODY
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            InkWell(onTap: canComplete ? onToggle : null, child: Opacity(opacity: canComplete ? 1.0 : 0.5, child: Container(margin: const EdgeInsets.only(top: 2, right: 10), width: 22, height: 22, decoration: BoxDecoration(border: Border.all(color: task.isCompleted ? priorityColor : Colors.grey.shade600, width: 1.5), borderRadius: BorderRadius.circular(6), color: task.isCompleted ? priorityColor : Colors.transparent), child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.black) : null))),
                            Expanded(child: Text(task.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: task.isCompleted ? Colors.grey.shade600 : Colors.white, decoration: task.isCompleted ? TextDecoration.lineThrough : null), maxLines: 2, overflow: TextOverflow.ellipsis))
                        ]),
                        // LOADING BAR
                        if (totalSub > 0) Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: TweenAnimationBuilder<double>(tween: Tween<double>(begin: 0, end: progress), duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic, builder: (context, value, child) => ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: value, backgroundColor: Colors.black26, valueColor: AlwaysStoppedAnimation(task.isCompleted ? Colors.grey : const Color(0xFF2EA063)), minHeight: 6)))),
                        const SizedBox(height: 12),
                        // FOOTER
                        Row(children: [
                            if (task.assignee != null && task.assignee!.isNotEmpty) Container(padding: const EdgeInsets.all(5), margin: const EdgeInsets.only(right: 8), decoration: const BoxDecoration(color: Color(0xFF374151), shape: BoxShape.circle), child: Text(task.assignee![0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
                            Icon(Icons.calendar_today, size: 13, color: dateColor), const SizedBox(width: 4), Text(dateStr, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: dateColor, fontWeight: FontWeight.w800)),
                            const Spacer(),
                            if (totalSub > 0) ...[Icon(Icons.checklist, size: 14, color: Colors.grey[400]), const SizedBox(width: 4), Text("$completedSub/$totalSub", style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400])), const SizedBox(width: 12)],
                            Flexible(child: Text(task.priorityLabel.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis))
                        ])
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
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF374151))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: Colors.grey[400]), const SizedBox(width: 4), Flexible(child: Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[300]), overflow: TextOverflow.ellipsis))]));
  }
}