import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../models/task_model.dart';
import '../../../controllers/task_controller.dart';
import 'task_details_dialog.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>(); 
    final canDelete = controller.canCreateOrDelete;
    final bool userCanComplete = controller.canComplete(task);
    
    final categoryItem = controller.categories.firstWhere(
      (c) => c.label == task.category,
      orElse: () => controller.categories.first
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    Color dateColor = Colors.grey[500]!;
    if (!task.isCompleted) {
      if (taskDate.isBefore(today)) {
        dateColor = AppColors.statusLate;
      } else if (taskDate.isAtSameMomentAs(today)) {
        dateColor = AppColors.statusPending;
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        dateColor = const Color(0xFFEAB308);
      }
    }
    
    final dateStr = DateFormat('dd MMM', 'pt_BR').format(task.dueDate).toUpperCase();

    return InkWell(
      onTap: () {
        showDialog(
          context: context, 
          builder: (_) => TaskDetailsDialog(task: task)
        );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  _tag(categoryItem.label, categoryItem.icon, Colors.grey),
                  if(canDelete) 
                    GestureDetector(
                      onTap: () => controller.deleteTask(task.id), 
                      child: Icon(Icons.more_horiz, size: 16, color: Colors.grey)
                    )
                ]
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: userCanComplete ? onToggle : null, 
                    child: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.circle_outlined, 
                      color: task.isCompleted ? AppColors.primary : Colors.grey, 
                      size: 20
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title, 
                      style: GoogleFonts.inter(
                        color: Colors.white, 
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null
                      )
                    )
                  ),
                ]
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: dateColor), 
                  const SizedBox(width: 4), 
                  Text(dateStr, style: TextStyle(color: dateColor, fontSize: 11))
                ]
              )
            ]
          ),
        ),
      ),
    );
  }

  Widget _tag(String t, IconData i, Color c) {
    return Container(
      padding: const EdgeInsets.all(4), 
      decoration: BoxDecoration(
        color: Colors.black26, 
        borderRadius: BorderRadius.circular(4)
      ), 
      child: Row(
        children: [
          Icon(i, size: 10, color: c), 
          const SizedBox(width: 4), 
          Text(t, style: TextStyle(color: c, fontSize: 10))
        ]
      )
    );
  }
}