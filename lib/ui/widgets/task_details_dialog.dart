import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';

class TaskDetailsDialog extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsDialog({super.key, required this.task});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _subTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    // Busca a task atualizada
    final task = controller.filteredTasks.firstWhere(
      (t) => t.id == widget.task.id, 
      orElse: () => widget.task
    );

    final dateStr = DateFormat('dd/MM/yyyy').format(task.dueDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ESQUERDA
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: task.priorityColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(task.priorityLabel.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: task.priorityTextColor)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade700), borderRadius: BorderRadius.circular(4)),
                          child: Text(task.categoryLabel.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        const Spacer(),
                        // Dropdown Status
                        DropdownButton<String>(
                          value: controller.statuses.contains(task.status) ? task.status : controller.statuses.first,
                          underline: const SizedBox(),
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          dropdownColor: const Color(0xFF1F2937),
                          items: controller.statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) { if (val != null) controller.updateTaskStatus(task.id, val); },
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(task.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text("Descrição", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(task.description.isEmpty ? "Sem descrição." : task.description, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade300, height: 1.5)),
                    const SizedBox(height: 32),
                    
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Checklist", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text("${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}", style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                        Expanded(child: TextField(controller: _subTaskController, decoration: const InputDecoration(hintText: "Adicionar item...", isDense: true), onSubmitted: (val) { if(val.isNotEmpty) { controller.addSubTask(task.id, val); _subTaskController.clear(); } })),
                        IconButton(icon: const Icon(Icons.add_circle), color: const Color(0xFF2EA063), onPressed: () { if(_subTaskController.text.isNotEmpty) { controller.addSubTask(task.id, _subTaskController.text); _subTaskController.clear(); } })
                    ]),
                    const SizedBox(height: 12),
                    ...task.subtasks.map((sub) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
                      child: ListTile(
                        dense: true,
                        leading: Checkbox(value: sub.isCompleted, activeColor: const Color(0xFF2EA063), onChanged: (val) => controller.toggleSubTask(task.id, sub.id)),
                        title: Text(sub.title, style: GoogleFonts.inter(decoration: sub.isCompleted ? TextDecoration.lineThrough : null, color: sub.isCompleted ? Colors.grey : Colors.white)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey), onPressed: () => controller.removeSubTask(task.id, sub.id)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            Container(width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 32)),
            // DIREITA
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.calendar_today, "Entrega", dateStr),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person, "Responsável", task.assignee ?? "Não atribuído"),
                  const SizedBox(height: 16),
                  if (task.client != null) _buildInfoRow(Icons.business, "Cliente", task.client!),
                  const Divider(height: 48, color: Colors.white10),
                  Text("Comentários", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: task.comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = task.comments[index];
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(comment.author, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(width: 8), Text(DateFormat('dd/MM HH:mm').format(comment.date), style: GoogleFonts.inter(color: Colors.grey, fontSize: 10))]), const SizedBox(height: 4), Text(comment.content, style: GoogleFonts.inter(color: Colors.grey.shade300, fontSize: 13))]);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Comentar...", isDense: true), onSubmitted: (val) { if(val.isNotEmpty) { controller.addComment(task.id, val); _commentController.clear(); } })), IconButton.filled(onPressed: () { if(_commentController.text.isNotEmpty) { controller.addComment(task.id, _commentController.text); _commentController.clear(); } }, icon: const Icon(Icons.send, size: 18))]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)), Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600))])]);
  }
}