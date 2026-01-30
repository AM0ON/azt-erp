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
    final primaryColor = Theme.of(context).primaryColor;
    
    final userRole = controller.userRole;
    final canAddCategory = userRole == '_CTO' || userRole == '_GESTAO';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Certifique-se que este caminho de asset existe no seu projeto
          icon: SvgPicture.asset('lib/assets/icones/horario-comercial.svg', width: 24, height: 24, color: const Color(0xFF2EA063)),
          tooltip: "Voltar ao Hub",
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text('DashBoard Tasks', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(4)
              ),
              child: Text(
                "PROJETOS", 
                style: GoogleFonts.jetBrainsMono( 
                  fontSize: 10, 
                  color: primaryColor, 
                  fontWeight: FontWeight.bold
                )
              ),
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
                Text("Prod Works", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -1)),
                Text(
                  "SPRINT ATUAL", 
                  style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- LISTA DE FILTROS ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...controller.categories.map((category) {
                    return _buildFilterTab(
                      context, 
                      category.label,
                      category.icon
                    );
                  }),

                  if (canAddCategory) 
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Tooltip(
                        message: "Adicionar Nova Categoria",
                        child: InkWell(
                          onTap: () => _showAddCategoryDialog(context),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  "Nova", 
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)
                                ),
                              ],
                            ),
                          ),
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
        Text(title, 
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: isGrey ? Colors.grey[500] : Colors.grey[700],
              letterSpacing: 0.5
            )),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(
            count.toString(), 
            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])
          ),
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
          crossAxisCount: crossAxisCount,
          mainAxisExtent: 155, 
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: tasks.length,
        itemBuilder: (ctx, i) => TaskCard(
          task: tasks[i], 
          onToggle: () => controller.toggleTaskCompletion(tasks[i].id)
        ),
      );
    });
  }

  Widget _buildFilterTab(BuildContext context, String label, IconData icon) {
    final controller = context.read<TaskController>();
    final isSelected = context.select<TaskController, bool>((c) => c.currentFilter == label);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => controller.setFilter(label),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? const Color(0xFF111827) : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                size: 16, 
                color: isSelected ? Colors.white : Colors.grey.shade500
              ),
              const SizedBox(width: 8),
              Text(
                label, 
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600, 
                  color: isSelected ? Colors.white : Colors.grey.shade700
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIÁLOGO DE NOVA CATEGORIA COM ICON PICKER ---
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final textController = TextEditingController();
    
    // Lista de ícones disponíveis para escolha
    final List<IconData> availableIcons = [
      Icons.bookmark_outline,
      Icons.flag_outlined,
      Icons.work_outline,
      Icons.shopping_cart_outlined,
      Icons.computer,
      Icons.build_outlined,
      Icons.science_outlined,
      Icons.palette_outlined,
      Icons.public,
      Icons.security,
      Icons.cloud_queue,
      Icons.chat_bubble_outline,
    ];

    // Ícone selecionado inicialmente
    IconData selectedIcon = availableIcons[0];

    await showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder permite atualizar o estado (ícone selecionado) dentro do Dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              child: Container(
                width: 380, // Um pouco mais largo para caber os ícones
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nova Categoria", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // Input de Nome
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        labelText: "Nome",
                        hintText: "Ex: Marketing",
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Text("Ícone", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    const SizedBox(height: 10),

                    // --- ICON PICKER (GRID) ---
                    Container(
                      height: 120, // Altura fixa para scrollar se precisar
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableIcons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2EA063).withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2EA063) : Colors.grey.shade200
                                  )
                                ),
                                child: Icon(
                                  icon, 
                                  size: 20, 
                                  color: isSelected ? const Color(0xFF2EA063) : Colors.grey.shade400
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // --------------------------

                    const SizedBox(height: 24),
                    
                    // Botões de Ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              // Passa o nome e o ícone selecionado
                              context.read<TaskController>().addCategory(textController.text, selectedIcon);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Adicionar"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog(context: context, builder: (_) => const AddTaskDialog());
    
    if (result != null && context.mounted) {
      final newTask = TaskModel(
        id: DateTime.now().toString(),
        title: result['title'],
        description: result['desc'],
        dueDate: result['date'] ?? DateTime.now(),
        category: TaskCategory.values.firstWhere(
          (e) => e.toString().contains(result['category']), 
          orElse: () => TaskCategory.pessoal
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == result['priority'], 
          orElse: () => TaskPriority.media
        ),
      );
      
      context.read<TaskController>().addTask(newTask);
    }
  }
}