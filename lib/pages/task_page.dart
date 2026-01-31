import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../ui/widgets/task_card.dart';
import '../ui/widgets/add_task_dialog.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final primaryColor = const Color(0xFF2EA063); // AzorTech Green
    final isManager = controller.isManager;
    final bgColor = const Color(0xFF111827); // Dark BG

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: SvgPicture.asset('lib/assets/icones/horario-comercial.svg', width: 20, height: 20, color: primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Row(
          children: [
            Text('Fluxo de Trabalho', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primaryColor.withOpacity(0.3))
              ),
              child: Text("KANBAN", style: GoogleFonts.jetBrainsMono(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        actions: [
          _buildHeaderAction(Icons.search),
          const SizedBox(width: 8),
          _buildHeaderAction(Icons.filter_list),
          const SizedBox(width: 24),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Nova Tarefa", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddTaskDialog(context),
      ),
      
      body: Column(
        children: [
          // BARRA DE FILTROS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FILTROS DE VISUALIZAÇÃO", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...controller.categories.map((c) => _buildFilterTab(context, c, controller, isManager)),
                      if (isManager) 
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: InkWell(
                            onTap: () => _showAddCategoryDialog(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[700]!, style: BorderStyle.solid)
                              ),
                              child: Row(children: [
                                const Icon(Icons.add, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text("Categoria", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey))
                              ]),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // KANBAN SCROLL
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              children: [
                ...controller.statuses.map((status) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _buildKanbanColumn(context, status, controller.filteredTasks, controller, isManager),
                  )
                ),
                
                // Botão "Adicionar Quadro" (Corrigido: BorderStyle.solid)
                if (isManager)
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: InkWell(
                      onTap: () => _showAddStatusDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 300,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          // [CORREÇÃO] Removido style: BorderStyle.dashed
                          border: Border.all(color: Colors.white10, width: 1.5), 
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 8),
                              Text("Adicionar Quadro", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(width: 48), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
      child: Icon(icon, size: 20, color: Colors.grey[400]),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String title, List<TaskModel> allTasks, TaskController controller, bool isManager) {
    final tasks = allTasks.where((t) => t.status == title).toList();
    // Dummy para pegar a cor consistente
    final dummy = TaskModel(id: '', title: '', description: '', dueDate: DateTime.now(), category: '', priority: TaskPriority.baixa, status: title);
    final color = dummy.statusColor;

    return DragTarget<String>(
      onAccept: (id) => controller.updateTaskStatus(id, title),
      builder: (context, candidate, rejected) {
        return Container(
          width: 340, 
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidate.isNotEmpty ? color.withOpacity(0.5) : Colors.transparent,
              width: 2
            )
          ),
          child: Column(
            children: [
              // Header da Coluna
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 12),
                        Text(title.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey[300], letterSpacing: 0.5)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
                          child: Text(tasks.length.toString(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        )
                      ],
                    ),
                    if (isManager && title != "A Fazer" && title != "Concluído") 
                      IconButton(icon: Icon(Icons.more_horiz, size: 18, color: Colors.grey[600]), onPressed: () => controller.removeStatus(title))
                  ],
                ),
              ),
              
              // Lista
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => Draggable<String>(
                    data: tasks[i].id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(width: 300, child: Opacity(opacity: 0.9, child: TaskCard(task: tasks[i], onToggle: () {}))),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: TaskCard(task: tasks[i], onToggle: () {})),
                    child: TaskCard(task: tasks[i], onToggle: () => controller.toggleTaskCompletion(tasks[i].id))
                  )
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(BuildContext context, CategoryItem cat, TaskController controller, bool isManager) {
    final isSelected = controller.currentFilter == cat.label;
    final color = Theme.of(context).primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => controller.setFilter(cat.label),
        onLongPress: (isManager && cat.label != "Todas") ? () => controller.removeCategory(cat.label) : null,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? color : Colors.white10),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : []
          ),
          child: Row(
            children: [
              Icon(cat.icon, size: 16, color: isSelected ? Colors.white : Colors.grey[400]),
              const SizedBox(width: 8),
              Text(cat.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddStatusDialog(BuildContext context) async {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => _ModernDialog(title: "Novo Quadro", child: TextField(controller: c, decoration: _inputDeco("Nome da Coluna")), onConfirm: (){ if(c.text.isNotEmpty) { context.read<TaskController>().addStatus(c.text); Navigator.pop(ctx); }}));
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => _ModernDialog(title: "Nova Categoria", child: TextField(controller: c, decoration: _inputDeco("Nome da Categoria")), onConfirm: (){ if(c.text.isNotEmpty) { context.read<TaskController>().addCategory(c.text, Icons.label_outline); Navigator.pop(ctx); }}));
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => const AddTaskDialog());
    if (result != null && context.mounted) {
      final ctrl = context.read<TaskController>();
      List<SubTask> subs = [];
      if (result['subtasks'] != null) {
        subs = (result['subtasks'] as List<String>).map((t) => SubTask(id: DateTime.now().toString() + t.hashCode.toString(), title: t)).toList();
      }
      ctrl.addTask(TaskModel(id: DateTime.now().toString(), title: result['title'], description: result['desc'], client: result['client'], assignee: result['assignee'], dueDate: result['date'], category: result['category'], priority: TaskPriority.values.firstWhere((e) => e.name == result['priority'], orElse: () => TaskPriority.media), status: ctrl.statuses.first, subtasks: subs));
    }
  }
}

// Helpers de Estilo
InputDecoration _inputDeco(String label) => InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFF111827), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), labelStyle: TextStyle(color: Colors.grey[500]));

class _ModernDialog extends StatelessWidget {
  final String title; final Widget child; final VoidCallback onConfirm;
  const _ModernDialog({required this.title, required this.child, required this.onConfirm});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16), child, const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: TextStyle(color: Colors.grey[400]))),
            const SizedBox(width: 8),
            FilledButton(onPressed: onConfirm, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2EA063)), child: const Text("Criar"))
          ])
        ]),
      ),
    );
  }
}