import 'package:azt_tasks/ui/pages/hub_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart'; // Certifique-se que este import está correto
import '../ui/pages/hub_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta se é mobile ou desktop para ajustar o layout
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      body: Row(
        children: [
          // LADO ESQUERDO (Banner Escuro - Branding)
          // Só aparece se NÃO for mobile
          if (!isMobile)
            Expanded(
              flex: 5, 
              child: Container(
                color: const Color(0xFF111827), // Fundo Dark Oficial
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Circular
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2EA063), width: 3), // Borda Verde
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_enhance_rounded, size: 50, color: Color(0xFF2EA063)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título da Marca
                    Text(
                      "AzorTech ERP",
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Slogan Monospace
                    Text(
                      "Gestão e produção Integrados",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // LADO DIREITO (Formulário Branco)
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white, // Fundo Branco Limpo
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Acesso Restrito",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827), // Texto Escuro
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Faça login para acessar os módulos.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 48),

                          // INPUT EMAIL
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "E-mail Corporativo",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400], size: 20),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA063))),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // INPUT SENHA
                          TextField(
                            obscureText: true,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Senha",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA063))),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // BOTÃO DE ENTRAR (Corrigido para Verde/Brand)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2EA063), // Verde AzorTech
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25), // Pill Shape
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HubPage()),
                                );
                              },
                              child: Text(
                                "Entrar no Sistema",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FOOTER (Copyright)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        "© 2026 AzorTech Software & e-Brand Solutions LTDA",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}