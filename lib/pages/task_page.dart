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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // CORREÇÃO: Usando Ícone Nativo para evitar erro de Asset
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
          IconButton(onPressed: (){}, icon: const Icon(Icons.search, size: 24)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.filter_list, size: 24)),
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
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Prod Works", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -1, color: Colors.white)),
                Text("SPRINT ATUAL", style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...controller.categories.map((category) => _buildFilterTab(context, category.label, category.icon)),
                  if (canAddCategory) 
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () => _showAddCategoryDialog(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF374151)),
                          ),
                          child: Row(children: [Icon(Icons.add, size: 16, color: Colors.grey.shade400), const SizedBox(width: 4), Text("Nova", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400))]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionHeader(context, "BACKLOG", controller.activeTasks.length),
            const SizedBox(height: 16),
            _buildGrid(controller.activeTasks, controller),

            const SizedBox(height: 40),

            if (controller.completedTasks.isNotEmpty) ...[
              _buildSectionHeader(context, "CONCLUÍDAS", controller.completedTasks.length, isGrey: true),
              const SizedBox(height: 16),
              Opacity(
                opacity: 0.6,
                child: _buildGrid(controller.completedTasks, controller),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, {bool isGrey = false}) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: isGrey ? Colors.grey[600] : Colors.grey[400])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(4)),
          child: Text(count.toString(), style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400]))
        )
      ],
    );
  }

  Widget _buildGrid(List<TaskModel> tasks, TaskController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth > 1400 ? 4 : (constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, mainAxisExtent: 155, crossAxisSpacing: 16, mainAxisSpacing: 16,
        ),
        itemCount: tasks.length,
        itemBuilder: (ctx, i) => TaskCard(task: tasks[i], onToggle: () => controller.toggleTaskCompletion(tasks[i].id)),
      );
    });
  }

  Widget _buildFilterTab(BuildContext context, String label, IconData icon) {
    final controller = context.read<TaskController>();
    final isSelected = context.select<TaskController, bool>((c) => c.currentFilter == label);
    final primaryColor = Theme.of(context).primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => controller.setFilter(label),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? primaryColor : const Color(0xFF374151)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade300)),
            ],
          ),
        ),
      ),
    );
  }

  // Mantive a lógica de adicionar categoria simplificada aqui para não extender demais
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    // ... Mesmo código do dialog de categoria anterior ...
    // Se precisar, posso reenviar, mas é o mesmo bloco que já existia
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => const AddTaskDialog());
    
    if (result != null && context.mounted) {
      final newTask = TaskModel(
        id: DateTime.now().toString(),
        title: result['title'],
        description: result['desc'],
        client: result['client'], // Recebendo Cliente
        assignee: result['assignee'], // Recebendo Responsável
        dueDate: result['date'] ?? DateTime.now(),
        category: TaskCategory.values.firstWhere((e) => e.toString().contains(result['category']), orElse: () => TaskCategory.pessoal),
        priority: TaskPriority.values.firstWhere((e) => e.name == result['priority'], orElse: () => TaskPriority.media),
      );
      context.read<TaskController>().addTask(newTask);
    }
  }
}