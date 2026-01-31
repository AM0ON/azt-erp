import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'add_task_dialog.dart'; // [IMPORTANTE] Agora importa o Dialog de Edição

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TaskController>();
    final canDelete = controller.canCreateOrDelete;
    final canComplete = !task.isCompleted;

    // Lógica de Cores
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    Color dateColor = Colors.grey[500]!;
    if (!task.isCompleted) {
      if (taskDate.isBefore(today)) dateColor = const Color(0xFFEF4444);
      else if (taskDate.isAtSameMomentAs(today)) dateColor = const Color(0xFFF59E0B);
    }
    
    final dateStr = DateFormat('dd MMM', 'pt_BR').format(task.dueDate).toUpperCase();
    final totalSub = task.subtasks.length;
    final completedSub = task.subtasks.where((s) => s.isCompleted).length;
    final double progress = totalSub > 0 ? completedSub / totalSub : 0.0;

    return InkWell(
      // [ALTERAÇÃO] Abre o Dialog de Edição ao clicar, passando a task atual
      onTap: () => _showEditDialog(context, controller),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: task.isCompleted ? Colors.transparent : Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6, runSpacing: 6,
                              children: [
                                _buildTag(task.categoryLabel, task.categoryIcon, Colors.grey[400]!),
                                _buildTag(task.statusLabel, Icons.circle, task.statusColor, isStatus: true),
                                if (task.client != null && task.client!.isNotEmpty) _buildTag(task.client!, Icons.business, Colors.blueAccent),
                              ],
                            ),
                          ),
                          if (canDelete) GestureDetector(onTap: () => controller.deleteTask(task.id), child: Icon(Icons.more_horiz, size: 16, color: Colors.grey[600]))
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: canComplete ? onToggle : null,
                            child: Container(
                              margin: const EdgeInsets.only(top: 2, right: 10), width: 20, height: 20,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: task.isCompleted ? task.priorityTextColor : Colors.grey[600]!, width: 2), color: task.isCompleted ? task.priorityTextColor : Colors.transparent),
                              child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                            ),
                          ),
                          Expanded(child: Text(task.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: task.isCompleted ? Colors.grey[500] : Colors.white, decoration: task.isCompleted ? TextDecoration.lineThrough : null, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (task.assignee != null && task.assignee!.isNotEmpty) Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF374151), shape: BoxShape.circle), child: Text(task.assignee![0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
                          Icon(Icons.access_time_rounded, size: 14, color: dateColor), const SizedBox(width: 4), Text(dateStr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: dateColor)),
                          const Spacer(),
                          if (totalSub > 0) ...[Icon(Icons.checklist_rounded, size: 16, color: Colors.grey[500]), const SizedBox(width: 4), Text("$completedSub/$totalSub", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]))]
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(left: 0, top: 12, bottom: 12, child: Container(width: 3, decoration: BoxDecoration(color: task.priorityTextColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(2), bottomRight: Radius.circular(2))))),
              ],
            ),
            if (totalSub > 0) ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation(task.isCompleted ? Colors.grey : const Color(0xFF2EA063)), minHeight: 4)),
          ],
        ),
      ),
    );
  }

  // Abre o diálogo de edição e salva as alterações
  Future<void> _showEditDialog(BuildContext context, TaskController controller) async {
    // Verifica permissão básica de edição
    if (!controller.canEdit(task)) return;

    final result = await showDialog(
      context: context, 
      builder: (_) => AddTaskDialog(taskToEdit: task)
    );

    if (result != null && context.mounted) {
      // Reconstrói as subtasks (simplificação)
      List<SubTask> updatedSubtasks = [];
      if (result['subtasks'] != null) {
        // Mantém IDs antigos se possível, ou cria novos. Aqui vamos recriar para simplificar a demo.
        updatedSubtasks = (result['subtasks'] as List<String>).map((t) => SubTask(id: DateTime.now().toString() + t.hashCode.toString(), title: t)).toList();
      }

      // Atualiza o objeto Task
      final updatedTask = TaskModel(
        id: task.id,
        title: result['title'],
        description: result['desc'],
        client: result['client'],
        assignee: result['assignee'],
        dueDate: result['date'],
        category: result['category'],
        priority: TaskPriority.values.firstWhere((e) => e.name == result['priority'], orElse: () => TaskPriority.media),
        status: task.status, // Mantém o status onde estava
        comments: task.comments, // Mantém comentários
        subtasks: updatedSubtasks, 
      );

      controller.updateTask(updatedTask);
    }
  }

  Widget _buildTag(String text, IconData icon, Color color, {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isStatus ? color.withOpacity(0.1) : const Color(0xFF111827), borderRadius: BorderRadius.circular(6), border: Border.all(color: isStatus ? color.withOpacity(0.2) : Colors.white10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [if (!isStatus) ...[Icon(icon, size: 10, color: color), const SizedBox(width: 4)], Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: isStatus ? color : Colors.grey[400]))]),
    );
  }
}