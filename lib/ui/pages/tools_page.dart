import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../controllers/task_controller.dart';

class ExternalTool { final String name, url, category; final IconData icon; final Color color; final List<String> allowedRoles; ExternalTool({required this.name, required this.url, required this.icon, required this.color, required this.category, required this.allowedRoles}); }

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});
  static List<ExternalTool> get _allTools => [
    ExternalTool(name: 'Slack', url: 'https://slack.com', icon: Icons.chat, color: Colors.purple, category: 'Geral', allowedRoles: []),
    ExternalTool(name: 'AWS', url: 'https://aws.amazon.com', icon: Icons.cloud, color: Colors.orange, category: 'DevOps', allowedRoles: ['_CTO', '_DEV']),
    ExternalTool(name: 'Banco', url: 'https://banco.com', icon: Icons.account_balance, color: Colors.green, category: 'Financeiro', allowedRoles: ['_CTO', '_FIN']),
  ];

  @override
  Widget build(BuildContext context) {
    final role = context.watch<TaskController>().userRole;
    final tools = _allTools.where((t) => t.allowedRoles.isEmpty || t.allowedRoles.contains(role)).toList();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Ferramentas")),
      body: GridView.builder(padding: const EdgeInsets.all(24), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5), itemCount: tools.length, itemBuilder: (c, i) => _Card(tool: tools[i])),
    );
  }
}
class _Card extends StatelessWidget { final ExternalTool tool; const _Card({required this.tool}); @override Widget build(BuildContext context) => InkWell(onTap: () => launchUrl(Uri.parse(tool.url)), child: Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(tool.icon, color: tool.color, size: 32), const SizedBox(height: 8), Text(tool.name, style: const TextStyle(color: Colors.white))]))); }