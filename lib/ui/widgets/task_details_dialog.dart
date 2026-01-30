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
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final displayId = "ID-${task.id.padLeft(4, '0')}";
    // Usando cores do tema
    final surfaceColor = Theme.of(context).cardTheme.color;
    final dividerColor = Theme.of(context).dividerTheme.color;

    return Dialog(
      // Fundo e Borda definidos no main.dart (DialogTheme)
      child: SizedBox(
        width: 600, height: 700,
        child: Column(
          children: [
            // HEADER
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
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editTask(context)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  )
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(task.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: task.priorityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text(task.priorityLabel.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: task.priorityColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text("DESCRIÇÃO", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const SizedBox(height: 8),
                    Text(task.description, style: GoogleFonts.inter(fontSize: 16, height: 1.5, color: Colors.grey[300])),
                    const SizedBox(height: 40),
                    
                    // COMENTÁRIOS
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 20),
                        const SizedBox(width: 8),
                        Text("Comentários", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (task.comments.isEmpty) Text("Nenhum comentário.", style: TextStyle(color: Colors.grey[600])),
                    ...task.comments.map((comment) => _buildCommentItem(comment)),
                  ],
                ),
              ),
            ),

            // INPUT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: dividerColor!)), color: Colors.black12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      // O estilo do TextField já vem do main.dart (escuro)
                      decoration: const InputDecoration(hintText: "Escreva um comentário..."),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      if(_commentController.text.isNotEmpty) {
                         context.read<TaskController>().addComment(task.id, _commentController.text);
                         _commentController.clear();
                         setState((){});
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(TaskComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.grey[800], child: Text(comment.author[0], style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(DateFormat('HH:mm').format(comment.date), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
                Text(comment.content, style: TextStyle(color: Colors.grey[300])),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _editTask(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => AddTaskDialog(taskToEdit: widget.task));
    if (result != null && context.mounted) {
       widget.task.title = result['title'];
       widget.task.description = result['desc'];
       widget.task.assignee = result['assignee'];
       widget.task.priority = TaskPriority.values.firstWhere((e) => e.name == result['priority']);
       context.read<TaskController>().updateTask(widget.task);
       setState(() {}); 
    }
  }
}