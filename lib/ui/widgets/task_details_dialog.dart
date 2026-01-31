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
  final _commentController = TextEditingController();
  final _subTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final task = controller.filteredTasks.firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
    
    // Define cor segura
    Color dateColor = Colors.grey;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    if (!task.isCompleted) {
      if (tDate.isBefore(today)) dateColor = Colors.redAccent;
      else if (tDate.isAtSameMomentAs(today)) dateColor = Colors.orangeAccent;
    }

    return Dialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 900, height: 700,
        child: Row(
          children: [
            // ESQUERDA: INFO PRINCIPAL
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white10))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statusChip(task.priorityLabel, task.priorityColor, task.priorityTextColor),
                        const SizedBox(width: 8),
                        _statusChip(task.categoryLabel, Colors.grey[800]!, Colors.white70),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(8)),
                          child: DropdownButton<String>(
                            value: controller.statuses.contains(task.status) ? task.status : controller.statuses.first,
                            dropdownColor: const Color(0xFF111827),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: task.statusColor),
                            items: controller.statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) { if(v!=null) controller.updateTaskStatus(task.id, v); },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(task.title, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 24),
                    _sectionTitle("Descrição"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(12)),
                      child: Text(task.description.isEmpty ? "Sem descrição" : task.description, style: GoogleFonts.inter(color: Colors.grey[400], height: 1.5)),
                    ),
                    const SizedBox(height: 32),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _sectionTitle("Checklist"),
                      Text("${task.subtasks.where((s)=>s.isCompleted).length}/${task.subtasks.length}", style: GoogleFonts.jetBrainsMono(color: Colors.grey))
                    ]),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: [
                          ...task.subtasks.map((sub) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              dense: true,
                              leading: Transform.scale(scale: 0.9, child: Checkbox(value: sub.isCompleted, activeColor: const Color(0xFF2EA063), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (v) => controller.toggleSubTask(task.id, sub.id))),
                              title: Text(sub.title, style: GoogleFonts.inter(decoration: sub.isCompleted ? TextDecoration.lineThrough : null, color: sub.isCompleted ? Colors.grey : Colors.white)),
                              trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.white24), onPressed: () => controller.removeSubTask(task.id, sub.id)),
                            ),
                          )),
                          TextField(
                            controller: _subTaskController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "+ Adicionar item", hintStyle: TextStyle(color: Colors.grey[600]), border: InputBorder.none,
                              prefixIcon: const Icon(Icons.add, color: Colors.grey)
                            ),
                            onSubmitted: (v) { if(v.isNotEmpty) { controller.addSubTask(task.id, v); _subTaskController.clear(); }},
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // DIREITA: SIDEBAR
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(32),
                color: const Color(0xFF111827).withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile(Icons.calendar_today, "Data de Entrega", DateFormat('dd/MM/yyyy').format(task.dueDate), color: dateColor),
                    const SizedBox(height: 24),
                    _infoTile(Icons.person, "Responsável", task.assignee ?? "Não atribuído", color: Colors.white),
                    const SizedBox(height: 24),
                    if(task.client != null) _infoTile(Icons.business, "Cliente", task.client!, color: Colors.blueAccent),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Divider(color: Colors.white10)),
                    
                    _sectionTitle("Atividade"),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: task.comments.length,
                        separatorBuilder: (_,__) => const SizedBox(height: 16),
                        itemBuilder: (ctx, i) {
                          final c = task.comments[i];
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CircleAvatar(radius: 12, backgroundColor: Colors.grey[800], child: Text(c.author[0], style: const TextStyle(fontSize: 10, color: Colors.white))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Text(c.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)), const SizedBox(width: 8), Text(DateFormat('HH:mm').format(c.date), style: TextStyle(fontSize: 10, color: Colors.grey[600]))]),
                              const SizedBox(height: 4),
                              Text(c.content, style: TextStyle(color: Colors.grey[400], fontSize: 13))
                            ]))
                          ]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Escrever comentário...", filled: true, fillColor: const Color(0xFF1F2937),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        suffixIcon: IconButton(icon: const Icon(Icons.send, size: 18, color: Color(0xFF2EA063)), onPressed: (){ if(_commentController.text.isNotEmpty) { controller.addComment(task.id, _commentController.text); _commentController.clear(); }})
                      ),
                      onSubmitted: (v) { if(v.isNotEmpty) { controller.addComment(task.id, v); _commentController.clear(); }}
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0));

  Widget _statusChip(String label, Color bg, Color text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: text)));

  Widget _infoTile(IconData icon, String label, String value, {required Color color}) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: Colors.grey[400])),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])), Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color))])
    ]);
  }
}