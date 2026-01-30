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

    // CORREÇÃO AQUI: Usamos padLeft para garantir que o ID tenha 4 dígitos (ex: 0001)
    // Isso evita o erro de substring em IDs curtos
    final String displayId = "ID-${task.id.padLeft(4, '0')}";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600,
        height: 700,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      displayId, 
                      style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: "Editar",
                        onPressed: () => _editTask(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Conteúdo Rolável
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: task.priorityColor,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            task.priorityLabel.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              color: task.priorityTextColor
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Descrição
                    Text("DESCRIÇÃO", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(task.description, style: GoogleFonts.inter(fontSize: 16, height: 1.5, color: Colors.black87)),

                    const SizedBox(height: 40),

                    // Área de Comentários
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 20),
                        const SizedBox(width: 8),
                        Text("Comentários", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    if (task.comments.isEmpty)
                      Text("Nenhum comentário ainda.", style: TextStyle(color: Colors.grey.shade400)),

                    ...task.comments.map((comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(comment.author.isNotEmpty ? comment.author[0] : "?", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(comment.author, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('HH:mm').format(comment.date), 
                                      style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(comment.content, style: GoogleFonts.inter(fontSize: 14)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),

            // Input de Comentário
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                color: Colors.grey.shade50
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Escreva um comentário...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        context.read<TaskController>().addComment(task.id, _commentController.text);
                        _commentController.clear();
                        setState(() {}); // Atualiza UI
                      }
                    },
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF2EA063)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext context) async {
    final result = await showDialog(
      context: context, 
      builder: (_) => AddTaskDialog(taskToEdit: widget.task)
    );
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