import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'add_task_dialog.dart';

class TaskDetailsDialog extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsDialog({super.key, required this.task});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final _commentController = TextEditingController();
  final _subtaskController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAddingSubtask = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final displayId = "ID-${task.id.padLeft(4, '0')}";
    final dividerColor = Theme.of(context).dividerTheme.color;

    return Dialog(
      child: SizedBox(
        width: 600, height: 700,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                    child: Text(displayId, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Row(children: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editTask(context)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))])
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                        Expanded(child: Text(task.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: task.priorityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(task.priorityLabel.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: task.priorityColor)))
                    ]),
                    const SizedBox(height: 24),
                    Text("DESCRIÇÃO", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const SizedBox(height: 8),
                    Text(task.description, style: GoogleFonts.inter(fontSize: 16, height: 1.5, color: Colors.grey[300])),
                    
                    const SizedBox(height: 40),
                    // SEÇÃO DE CHECKLIST
                    _buildSubtasksSection(context, task),
                    const SizedBox(height: 40),
                    
                    Row(children: [const Icon(Icons.chat_bubble_outline, size: 20), const SizedBox(width: 8), Text("Comentários", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
                    const SizedBox(height: 20),
                    if (task.comments.isEmpty) Text("Nenhum comentário.", style: TextStyle(color: Colors.grey[600])),
                    ...task.comments.map((comment) => _buildCommentItem(comment)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: dividerColor!)), color: Colors.black12),
              child: Row(children: [
                  Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Escreva um comentário..."))),
                  const SizedBox(width: 12),
                  IconButton.filled(onPressed: () { if(_commentController.text.isNotEmpty) { context.read<TaskController>().addComment(task.id, _commentController.text); _commentController.clear(); setState((){}); }}, icon: const Icon(Icons.send))
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksSection(BuildContext context, TaskModel task) {
    final controller = context.read<TaskController>();
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Icon(Icons.checklist, size: 20), const SizedBox(width: 8), Text("Checklist", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
            if (!_isAddingSubtask) IconButton(onPressed: () => setState(() => _isAddingSubtask = true), icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2EA063)))
        ]),
        const SizedBox(height: 16),
        if (_isAddingSubtask) Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [Expanded(child: TextField(controller: _subtaskController, autofocus: true, decoration: const InputDecoration(hintText: "Nova etapa...", contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)), onSubmitted: (_) => _addSubTask())), IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: _addSubTask), IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _isAddingSubtask = false))])),
        ...task.subtasks.map((sub) => Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: ListTile(dense: true, leading: Checkbox(value: sub.isCompleted, activeColor: const Color(0xFF2EA063), onChanged: (val) { controller.toggleSubTask(task.id, sub.id); setState(() {}); }), title: Text(sub.title, style: GoogleFonts.inter(decoration: sub.isCompleted ? TextDecoration.lineThrough : null, color: sub.isCompleted ? Colors.grey : Colors.white)), trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey), onPressed: () { controller.removeSubTask(task.id, sub.id); setState(() {}); })))),
      ],
    );
  }

  void _addSubTask() {
    if (_subtaskController.text.isNotEmpty) {
      context.read<TaskController>().addSubTask(widget.task.id, _subtaskController.text);
      _subtaskController.clear();
      setState(() => _isAddingSubtask = false);
    }
  }

  Widget _buildCommentItem(TaskComment comment) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 16, backgroundColor: Colors.grey[800], child: Text(comment.author[0], style: const TextStyle(color: Colors.white))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(width: 8), Text(DateFormat('HH:mm').format(comment.date), style: TextStyle(fontSize: 11, color: Colors.grey[500]))]), Text(comment.content, style: TextStyle(color: Colors.grey[300]))]))]));
  }

  void _editTask(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => AddTaskDialog(taskToEdit: widget.task));
    if (result != null && context.mounted) {
       widget.task.title = result['title']; widget.task.description = result['desc']; widget.task.assignee = result['assignee']; widget.task.priority = TaskPriority.values.firstWhere((e) => e.name == result['priority']);
       context.read<TaskController>().updateTask(widget.task);
       setState(() {}); 
    }
  }
}