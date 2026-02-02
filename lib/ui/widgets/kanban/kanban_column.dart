import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<TaskModel> tasks;
  final Color headerColor;
  final TaskStatus status;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.headerColor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: Text("${tasks.length}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          
          Expanded(
            child: tasks.isEmpty 
            ? Center(child: Text("Vazio", style: GoogleFonts.inter(color: Colors.white12)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _KanbanCard(task: tasks[index]);
                },
              ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final TaskModel task;

  const _KanbanCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  task.category.toUpperCase(), 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  task.priorityLabel, 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: task.priorityColor)
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(task.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description, 
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text("CT", style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
              
              Row(
                children: [
                  if (task.status != TaskStatus.todo)
                    _actionIcon(context, Icons.arrow_back, () {
                      final newStatus = task.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.todo;
                      context.read<TaskController>().updateTaskStatus(task.id, newStatus);
                    }),
                  
                  if (task.status != TaskStatus.done)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _actionIcon(context, Icons.arrow_forward, () {
                        final newStatus = task.status == TaskStatus.todo ? TaskStatus.inProgress : TaskStatus.done;
                        context.read<TaskController>().updateTaskStatus(task.id, newStatus);
                      }),
                    ),
                    
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => context.read<TaskController>().deleteTask(task.id),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _actionIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}