import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Administrativo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Módulo Financeiro em Desenvolvimento",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Aqui você gerenciará contratos e fluxo de caixa.",
              style: GoogleFonts.inter(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}