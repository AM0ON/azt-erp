import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports da Estrutura
import '../../core/app_colors.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../ui/widgets/kanban/filter_bar.dart';
import '../ui/widgets/kanban/kanban_column.dart';
import '../ui/widgets/add_task_dialog.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // "watch" escuta mudanças no controller para reconstruir a tela
    final controller = context.watch<TaskController>();
    final isManager = controller.isManager;

    return Scaffold(
      backgroundColor: AppColors.background,
      
      // --- HEADER (Barra de Título) ---
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
        title: Row(
          children: [
            Text(
              'Fluxo de Trabalho', 
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))
              ),
              child: Text(
                "KANBAN", 
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
        actions: [
          // Botão de Pesquisa (Exemplo visual)
          _buildHeaderAction(Icons.search, onTap: () {}),
          const SizedBox(width: 8),
          
          // Botão de Notificações com Badge
          Stack(
            children: [
              _buildHeaderAction(Icons.notifications_outlined, onTap: () => _showNotifications(context)),
              if (controller.unreadCount > 0)
                Positioned(
                  right: 8, 
                  top: 8, 
                  child: Container(
                    padding: const EdgeInsets.all(4), 
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      controller.unreadCount.toString(), 
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  )
                ),
            ],
          ),
          const SizedBox(width: 24),
        ],
      ),
      
      // --- BOTÃO FLUTUANTE (Adicionar Tarefa) ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Nova Tarefa", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddTaskDialog(context),
      ),
      
      // --- CORPO DA PÁGINA ---
      body: Column(
        children: [
          // 1. Barra de Filtros (Categorias)
          const FilterBar(),
          
          // 2. Área do Kanban (Colunas Horizontais)
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80), // Padding extra embaixo p/ FAB não tapar
              children: [
                // Gera uma coluna para cada Status definido no Controller
                ...controller.statuses.map((status) {
                  // Filtra as tarefas para esta coluna específica
                  final tasksForStatus = controller.filteredTasks
                      .where((t) => t.status == status)
                      .toList();
                  
                  return KanbanColumn(status: status, tasks: tasksForStatus);
                }),
                
                // Botão "Adicionar Coluna" (Apenas para Gestores)
                if (isManager)
                  _buildAddStatusButton(context),
                  
                const SizedBox(width: 48), // Espaço final
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS VISUAIS AUXILIARES ---

  Widget _buildHeaderAction(IconData icon, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10)
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.grey[400]),
        onPressed: onTap,
        tooltip: 'Ação',
      ),
    );
  }

  Widget _buildAddStatusButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 20),
      child: InkWell(
        onTap: () => _showAddStatusDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10, width: 1.5, style: BorderStyle.solid), 
            // Tracejado seria complexo nativamente, usaremos sólido sutil
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 32),
              const SizedBox(height: 12),
              Text(
                "Adicionar Quadro", 
                style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16)
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE DIALOGS ---

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final controller = context.read<TaskController>();
    
    // Abre o Dialog
    final result = await showDialog(
      context: context, 
      builder: (_) => const AddTaskDialog()
    );
    
    // Se o usuário salvou (result != null)
    if (result != null && context.mounted) {
       // Recupera Subtarefas do Map
       List<SubTask> subs = [];
       if (result['subtasks'] != null) {
         subs = (result['subtasks'] as List<String>)
             .map((t) => SubTask(id: DateTime.now().toString() + t.hashCode.toString(), title: t))
             .toList();
       }

       // Cria o Modelo
       final newTask = TaskModel(
         id: DateTime.now().toString(),
         title: result['title'],
         description: result['desc'],
         client: result['client'],
         assignee: result['assignee'],
         priority: TaskPriority.values.firstWhere(
           (e) => e.name == result['priority'], 
           orElse: () => TaskPriority.media
         ),
         category: result['category'],
         dueDate: result['date'],
         status: 'A Fazer', // Sempre começa em "A Fazer" ou o primeiro status da lista
         subtasks: subs
       );

       // Adiciona no Controller
       controller.addTask(newTask);
    }
  }

  Future<void> _showAddStatusDialog(BuildContext context) async {
    final controller = context.read<TaskController>();
    final textController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Novo Status", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Ex: Em Revisão", 
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary))
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancelar")
          ),
          TextButton(
            onPressed: () {
              if(textController.text.isNotEmpty) {
                controller.addStatus(textController.text);
                Navigator.pop(ctx);
              }
            }, 
            child: const Text("Adicionar", style: TextStyle(color: AppColors.primary))
          ),
        ],
      )
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notificações", 
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Nenhuma notificação nova.", 
                style: TextStyle(color: Colors.grey)
              )
            ),
          ],
        ),
      )
    );
  }
}