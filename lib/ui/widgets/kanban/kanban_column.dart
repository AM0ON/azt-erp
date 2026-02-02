import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String status;
  final List<TaskModel> tasks;

  const KanbanColumn({super.key, required this.status, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TaskController>();
    return DragTarget<String>(
      onAccept: (id) => controller.updateTaskStatus(id, status),
      builder: (context, candidate, rejected) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16), border: Border.all(color: candidate.isNotEmpty ? AppColors.primary : Colors.transparent)),
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey))),
            Expanded(child: ListView.separated(padding: const EdgeInsets.all(12), itemCount: tasks.length, separatorBuilder: (_,__) => const SizedBox(height: 12), itemBuilder: (ctx, i) => Draggable<String>(data: tasks[i].id, feedback: Material(color: Colors.transparent, child: SizedBox(width: 280, child: Opacity(opacity: 0.8, child: TaskCard(task: tasks[i], onToggle: (){})))), childWhenDragging: Opacity(opacity: 0.3, child: TaskCard(task: tasks[i], onToggle: (){})), child: TaskCard(task: tasks[i], onToggle: () => controller.toggleTaskCompletion(tasks[i].id)))))
          ]),
        );
      },
    );
  }
}