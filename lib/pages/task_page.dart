import 'package:azt_tasks/ui/widgets/kanban/filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../ui/widgets/kanban/filter_bar.dart'; 
import '../ui/widgets/add_task_dialog.dart'; 

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças no controller (Hive update -> Rebuild automático)
    final controller = context.watch<TaskController>();
    
    // Filtra as tarefas para cada coluna
    final todoTasks = controller.tasks.where((t) => t.status == TaskStatus.todo).toList();
    final doingTasks = controller.tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final doneTasks = controller.tasks.where((t) => t.status == TaskStatus.done).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8)
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Task Manager", 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.grey)),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Nova Tarefa", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        onPressed: () {
          showDialog(
            context: context, 
            builder: (_) => const AddTaskDialog()
          );
        },
      ),
      body: Column(
        children: [
          // Barra de Filtros (Categorias)
          const FilterBar(),
          
          // Área do Kanban (Scroll Horizontal para as Colunas)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn(context, "A Fazer", todoTasks, Colors.grey, TaskStatus.todo),
                  const SizedBox(width: 24),
                  _buildKanbanColumn(context, "Em Progresso", doingTasks, Colors.blueAccent, TaskStatus.inProgress),
                  const SizedBox(width: 24),
                  _buildKanbanColumn(context, "Concluído", doneTasks, Colors.greenAccent, TaskStatus.done),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String title, List<TaskModel> tasks, Color headerColor, TaskStatus status) {
    return Container(
      width: 320, // Largura fixa da coluna
      decoration: BoxDecoration(
        color: AppColors.surface, // Fundo da Coluna
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Cabeçalho da Coluna
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
          
          // Lista de Cards
          Expanded(
            child: tasks.isEmpty 
            ? Center(child: Text("Vazio", style: GoogleFonts.inter(color: Colors.white12)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(context, tasks[index]);
                },
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Card mais escuro que a coluna
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels (Categoria e Prioridade)
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
          
          // Título e Descrição
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

          // Rodapé do Card (Avatar e Ações)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar (Mock)
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text("CT", style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
              
              // Botões de Movimentação (Rápida)
              Row(
                children: [
                  if (task.status != TaskStatus.todo)
                    _actionIcon(Icons.arrow_back, () {
                      final newStatus = task.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.todo;
                      context.read<TaskController>().updateTaskStatus(task.id, newStatus);
                    }),
                  
                  if (task.status != TaskStatus.done)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _actionIcon(Icons.arrow_forward, () {
                        final newStatus = task.status == TaskStatus.todo ? TaskStatus.inProgress : TaskStatus.done;
                        context.read<TaskController>().updateTaskStatus(task.id, newStatus);
                      }),
                    ),
                    
                  // Delete Button
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

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
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