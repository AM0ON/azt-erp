import 'package:azt_tasks/pages/login_page.dart';
import 'package:azt_tasks/pages/task_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../controllers/task_controller.dart';
import 'task_page.dart';
import 'finance_page.dart';
import '../pages/hub_page.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final activeTasksCount = taskController.activeTasksCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),

            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatCard(context, "Tasks Ativas", activeTasksCount.toString(), Icons.data_usage, Colors.greenAccent),
                          const SizedBox(width: 16),
                          _buildStatCard(context, "Pendências", "3", Icons.warning_amber_rounded, Colors.orangeAccent),
                          const SizedBox(width: 16),
                          _buildStatCard(context, "Drive", "128", Icons.cloud_done_outlined, Colors.lightBlueAccent),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Text("APLICATIVOS", style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.5)),
                      const SizedBox(height: 16),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildAppCard(
                                context, 
                                title: "Task Manager", 
                                subtitle: "Projetos & Sprints", 
                                icon: Icons.check_circle, 
                                color: const Color(0xFF2EA063), 
                                destination: const TasksPage(), 
                                badge: "$activeTasksCount Ativas"
                              ),
                              _buildAppCard(
                                context, 
                                title: "Administrativo", 
                                subtitle: "Financeiro", 
                                icon: Icons.pie_chart, 
                                color: const Color(0xFF3B82F6), 
                                destination: const FinancePage()
                              ),
                              _buildAppCard(
                                context, 
                                title: "Recursos Humanos", 
                                subtitle: "Talentos & Ponto", 
                                icon: Icons.people_alt, 
                                color: const Color(0xFFF97316), 
                                isLocked: true
                              ),
                              _buildAppCard(
                                context, 
                                title: "AZT Drive", 
                                subtitle: "Arquivos", 
                                icon: Icons.folder_special, 
                                color: const Color(0xFF6366F1), 
                                isLocked: true, 
                                badge: "Beta"
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white10))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text("AzorTech ERP", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                
                // --- BOTÃO DE LOGOUT BLINDADO ---
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  tooltip: "Encerrar Sessão",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text("Encerrar Sessão?", style: TextStyle(color: Colors.white)),
                        content: const Text(
                          "Você será desconectado e retornará à tela de login.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () {
                              Navigator.pop(context); // Fecha o Dialog
                              
                              // DESTRÓI TODA A PILHA DE NAVEGAÇÃO
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage ()),
                                (Route<dynamic> route) => false, // Impede voltar
                              );
                            },
                            child: const Text("Sair"),
                          ),
                        ],
                      ),
                    );
                  },
                )
                // --------------------------------
              ],
            ),
            const Spacer(),
            Text("Bom dia, CTO.", style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Text("Visão geral do sistema.", style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400])),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, Widget? destination, bool isLocked = false, String? badge}) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLocked ? null : () { if(destination != null) Navigator.push(context, MaterialPageRoute(builder: (_) => destination)); },
        borderRadius: BorderRadius.circular(16),
        hoverColor: Colors.white.withOpacity(0.05),
        child: Container(
          width: 250, height: 180,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(isLocked ? Icons.lock : icon, color: isLocked ? Colors.grey : color, size: 32),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                    )
                ],
              ),
              const Spacer(),
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.white)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}