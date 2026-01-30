import 'package:azt_tasks/pages/task_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/widgets/task_card.dart'; // Módulo de Tasks
import 'admin_page.dart'; // Módulo Administrativo

class HubPage extends StatelessWidget {
  const HubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: Color(0xFF2EA063), size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AzorTech ERP', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('Internal System', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Módulos Disponíveis",
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
                ),
                const SizedBox(height: 32),
                
                // Grid de Módulos
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      children: [
                        // 1. TASKS (Verde)
                        _buildModuleCard(
                          context,
                          title: "Gestão de Tasks",
                          desc: "Backlog, Sprints e Controle de Projetos.",
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF2EA063),
                          destination: const TasksPage(),
                        ),
                        
                        // 2. ADMINISTRATIVO (Azul)
                        _buildModuleCard(
                          context,
                          title: "Administrativo",
                          desc: "Financeiro, Contratos e Fluxo de Caixa.",
                          icon: Icons.business_center_outlined,
                          color: const Color(0xFF3B82F6),
                          destination: const AdminPage(),
                        ),

                        // 3. RH (Laranja - NOVO)
                        _buildModuleCard(
                          context,
                          title: "Recursos Humanos",
                          desc: "Controle de ponto, férias e talentos.",
                          icon: Icons.people_alt_outlined,
                          color: const Color(0xFFF97316), // Orange 500
                          destination: null, // Ainda sem página
                          isLocked: false // Marcado como "Em breve"
                        ),

                        // 4. AZT DRIVE (Índigo - NOVO)
                        _buildModuleCard(
                          context,
                          title: "AZT Drive (DV)",
                          desc: "Gestão de arquivos e documentos seguros.",
                          icon: Icons.cloud_upload_outlined,
                          color: const Color(0xFF6366F1), // Indigo 500
                          destination: null, // Ainda sem página
                          isLocked: false // Marcado como "Em breve"
                        ),
                        
                        // 5. ANALYTICS (Roxo)
                        _buildModuleCard(
                          context,
                          title: "Analytics",
                          desc: "Métricas de performance e relatórios.",
                          icon: Icons.bar_chart_rounded,
                          color: Colors.purple.shade400,
                          destination: null,
                          isLocked: false
                        ),
                        // 4. AZT DRIVE (Índigo - NOVO)
                        _buildModuleCard(
                          context,
                          title: "Usuarios & Permissões",
                          desc: "Gestão de Acessos e Permissões.",
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF6366F1), // Indigo 500
                          destination: null, // Ainda sem página
                          isLocked: false // Marcado como "Em breve"
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
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title, 
    required String desc, 
    required IconData icon, 
    required Color color,
    Widget? destination,
    bool isLocked = false
  }) {
    const double cardWidth = 300;
    const double cardHeight = 220;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05), // Sombra mais suave
      child: InkWell(
        onTap: isLocked ? null : () {
          if (destination != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
          }
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withOpacity(0.05),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícone no topo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : icon, 
                  size: 32, 
                  color: isLocked ? Colors.grey : color
                ),
              ),
              
              // Textos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : const Color(0xFF111827)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 14, 
                      color: Colors.grey.shade600,
                      height: 1.4
                    ),
                  ),
                ],
              ),

              // Status
              Align(
                alignment: Alignment.centerRight,
                child: isLocked 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text("EM BREVE", style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))
                    )
                  : Icon(Icons.arrow_forward, color: Colors.grey.shade300, size: 20),
              )
            ],
          ),
        ),
      ),
    );
  }
}