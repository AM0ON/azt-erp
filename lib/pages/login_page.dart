import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/pages/hub_page.dart'; // Importa a nova Home do ERP
import 'package:flutter_svg/flutter_svg.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta se é tela pequena (Mobile/Tablet vertical)
    final isSmall = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Row(
        children: [
          // LADO ESQUERDO (Branding ERP - Só aparece em telas grandes)
          if (!isSmall)
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFF111827), // Fundo Dark Tech (Quase preto)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Simbolico
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EA063).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2EA063).withOpacity(0.3))
                      ),
                      child: SvgPicture.asset(
                        'lib/assets/icones/horario-comercial.svg',
                        width: 90,
                        height: 90,
                        color: const Color(0xFF2EA063),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título do ERP
                    Text(
                      "AzorTech ERP",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtítulo Técnico
                    Text(
                      "Gestão e produção Integrados",
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.grey[500],
                        fontSize: 14,
                        letterSpacing: -0.5
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // LADO DIREITO (Formulário de Login)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Acesso Restrito", 
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Text("Faça login para acessar os módulos.", 
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 40),
                        
                        // Inputs (Estilizados no main.dart)
                        TextField(
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: "E-mail Corporativo", 
                            prefixIcon: Icon(Icons.email_outlined, size: 20)
                          )
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: "Senha",
                            prefixIcon: Icon(Icons.lock_outline, size: 20)
                          ),
                          obscureText: true
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão Principal
                        FilledButton(
                          onPressed: () {
                            // REDIRECIONAMENTO CORRIGIDO: Vai para o HUB, não para Tasks
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => const HubPage())
                            );
                          },
                          child: const Text("Entrar no Sistema"),
                        ),

                        const SizedBox(height: 24),
                        
                        // Footer
                        Center(
                          child: Text(
                            "© 2026 AzorTech Software & e-Brand Solutions LTDA",
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey[400]),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}