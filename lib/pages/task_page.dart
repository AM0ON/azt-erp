import 'package:flutter/material.dart';
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
    final primaryColor = Theme.of(context).primaryColor;
    final userRole = controller.userRole;
    final canAddCategory = userRole == '_CTO' || userRole == '_GESTAO';
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).cardTheme.color;
    final borderColor = Theme.of(context).dividerTheme.color;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view, color: Color(0xFF2EA063)), 
          tooltip: "Voltar ao Hub",
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text('DashBoard Tasks', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text("PROJETOS", style: GoogleFonts.jetBrainsMono(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        actions: [
          // TOGGLE BUTTON (CORRIGIDO)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor!)
            ),
            child: Row(
              children: [
                _ViewToggleButton(icon: Icons.list, isActive: !controller.isKanbanMode, onTap: () => !controller.isKanbanMode ? null : controller.toggleViewMode()),
                Container(width: 1, height: 20, color: borderColor),
                _ViewToggleButton(icon: Icons.view_kanban, isActive: controller.isKanbanMode, onTap: () => controller.isKanbanMode ? null : controller.toggleViewMode()),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: Text("Nova Tarefa", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddTaskDialog(context),
      ),
      
      body: controller.isKanbanMode 
        ? _buildKanbanBody(context, controller, canAddCategory)
        : _buildListBody(context, controller, canAddCategory),
    );
  }

  Widget _buildListBody(BuildContext context, TaskController controller, bool canAddCategory) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Prod Works", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -1, color: Colors.white)),
              Text("VISÃO LISTA", style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(context, controller, canAddCategory),
          const SizedBox(height: 32),
          _buildSectionHeader(context, "BACKLOG", controller.activeTasks.length),
          const SizedBox(height: 16),
          _buildGrid(controller.activeTasks, controller),
          const SizedBox(height: 40),
          if (controller.completedTasks.isNotEmpty) ...[
            _buildSectionHeader(context, "CONCLUÍDAS", controller.completedTasks.length, isGrey: true),
            const SizedBox(height: 16),
            Opacity(opacity: 0.5, child: _buildGrid(controller.completedTasks, controller)),
          ]
        ],
      ),
    );
  }

  Widget _buildKanbanBody(BuildContext context, TaskController controller, bool canAddCategory) {
    final allTasks = controller.filteredTasks;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
          child: Column(
            children: [
               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Fluxo de Trabalho", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -1, color: Colors.white)),
                  Text("VISÃO KANBAN", style: GoogleFonts.jetBrainsMono(color: const Color(0xFF2EA063), fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              const SizedBox(height: 16),
              _buildFilters(context, controller, canAddCategory),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              _buildKanbanColumn(context, "TO DO", TaskStatus.todo, allTasks, controller),
              const SizedBox(width: 16),
              _buildKanbanColumn(context, "IN PROGRESS", TaskStatus.inProgress, allTasks, controller),
              const SizedBox(width: 16),
              _buildKanbanColumn(context, "REVIEW", TaskStatus.review, allTasks, controller),
              const SizedBox(width: 16),
              _buildKanbanColumn(context, "DONE", TaskStatus.done, allTasks, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String title, TaskStatus status, List<TaskModel> allTasks, TaskController controller) {
    final tasks = allTasks.where((t) => t.status == status).toList();
    final borderColor = Theme.of(context).dividerTheme.color!;
    final cardColor = Theme.of(context).cardTheme.color!;
    
    Color statusColor = status == TaskStatus.done ? Colors.green : (status == TaskStatus.inProgress ? Colors.orange : Colors.grey);

    return DragTarget<String>(
      onAccept: (taskId) => controller.updateTaskStatus(taskId, status),
      builder: (context, _, __) {
        return Container(
          width: 320,
          decoration: BoxDecoration(color: cardColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)), const SizedBox(width: 8), Text(title, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[300]))]), Text(tasks.length.toString(), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey))])),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    return LongPressDraggable<String>(
                      data: task.id,
                      feedback: SizedBox(width: 280, child: Opacity(opacity: 0.9, child: TaskCard(task: task, onToggle: () {}))),
                      childWhenDragging: Opacity(opacity: 0.3, child: TaskCard(task: task, onToggle: () {})),
                      child: TaskCard(task: task, onToggle: () => controller.toggleTaskCompletion(task.id)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, TaskController controller, bool canAddCategory) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [...controller.categories.map((c) => _buildFilterTab(context, c.label, c.icon)), if (canAddCategory) Padding(padding: const EdgeInsets.only(left: 8), child: InkWell(onTap: () => _showAddCategoryDialog(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF374151))), child: Row(children: [Icon(Icons.add, size: 16, color: Colors.grey.shade400), const SizedBox(width: 4), Text("Nova", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400))]))))]));
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, {bool isGrey = false}) {
    return Row(children: [Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: isGrey ? Colors.grey[600] : Colors.grey[400])), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(4)), child: Text(count.toString(), style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])))]);
  }

  Widget _buildGrid(List<TaskModel> tasks, TaskController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth > 1400 ? 4 : (constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
      return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisExtent: 155, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: tasks.length, itemBuilder: (ctx, i) => TaskCard(task: tasks[i], onToggle: () => controller.toggleTaskCompletion(tasks[i].id)));
    });
  }

  // BOTÕES FILTRO CORRIGIDOS (ZERO BRANCO)
  Widget _buildFilterTab(BuildContext context, String label, IconData icon) {
    final controller = context.read<TaskController>();
    final isSelected = context.select<TaskController, bool>((c) => c.currentFilter == label);
    final primaryColor = Theme.of(context).primaryColor;
    return Padding(padding: const EdgeInsets.only(right: 8), child: InkWell(onTap: () => controller.setFilter(label), borderRadius: BorderRadius.circular(6), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isSelected ? primaryColor : const Color(0xFF1F2937), borderRadius: BorderRadius.circular(6), border: Border.all(color: isSelected ? primaryColor : const Color(0xFF374151))), child: Row(children: [Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade400), const SizedBox(width: 8), Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade300))]))));
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final textController = TextEditingController();
    final List<IconData> availableIcons = [ Icons.bookmark, Icons.flag, Icons.work, Icons.shopping_cart, Icons.computer, Icons.build, Icons.science, Icons.palette, Icons.public, Icons.security, Icons.cloud, Icons.chat ];
    IconData selectedIcon = availableIcons[0];
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => Dialog(child: Container(width: 400, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Nova Categoria", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 20), TextField(controller: textController, decoration: const InputDecoration(labelText: "Nome", prefixIcon: Icon(Icons.label))), const SizedBox(height: 20), Text("Ícone", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)), const SizedBox(height: 10), Container(height: 120, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade800), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(padding: const EdgeInsets.all(8), child: Wrap(spacing: 8, runSpacing: 8, children: availableIcons.map((icon) => InkWell(onTap: () => setState(() => selectedIcon = icon), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selectedIcon == icon ? const Color(0xFF2EA063).withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(4), border: Border.all(color: selectedIcon == icon ? const Color(0xFF2EA063) : Colors.grey.shade800)), child: Icon(icon, size: 20, color: selectedIcon == icon ? const Color(0xFF2EA063) : Colors.grey.shade400)))).toList()))), const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))), const SizedBox(width: 8), FilledButton(onPressed: () { if (textController.text.isNotEmpty) { context.read<TaskController>().addCategory(textController.text, selectedIcon); Navigator.pop(context); }}, child: const Text("Criar"))])])))));
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => const AddTaskDialog());
    if (result != null && context.mounted) {
      final newTask = TaskModel(id: DateTime.now().toString(), title: result['title'], description: result['desc'], client: result['client'], assignee: result['assignee'], dueDate: result['date'] ?? DateTime.now(), category: TaskCategory.values.firstWhere((e) => e.toString().contains(result['category']), orElse: () => TaskCategory.pessoal), priority: TaskPriority.values.firstWhere((e) => e.name == result['priority'], orElse: () => TaskPriority.media));
      context.read<TaskController>().addTask(newTask);
    }
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon; final bool isActive; final VoidCallback onTap;
  const _ViewToggleButton({required this.icon, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), color: isActive ? Theme.of(context).primaryColor : Colors.transparent, child: Icon(icon, size: 20, color: isActive ? Colors.white : Colors.grey)));
  }
}