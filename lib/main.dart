import 'package:azt_tasks/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORTS DOS SERVIÇOS ---
import 'services/storage_service.dart';

// --- IMPORTS DOS CONTROLLERS ---
import 'controllers/task_controller.dart';
import 'controllers/finance_controller.dart';
import 'controllers/client_controller.dart';

// --- IMPORTS DAS PAGES ---
import '../pages/login_page.dart';

void main() async {
  // 1. Garante que a Engine do Flutter está pronta
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa a formatação de datas (PT-BR)
  await initializeDateFormatting('pt_BR', null);

  // 3. 🚀 INICIALIZA O BANCO DE DADOS CRIPTOGRAFADO (Hive)
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => FinanceController()),
        ChangeNotifierProvider(create: (_) => ClientController()),
      ],
      child: const AzorTechApp(),
    ),
  );
}

class AzorTechApp extends StatelessWidget {
  const AzorTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AzorTech ERP',
      debugShowCheckedModeBanner: false,
      
      // Tema Dark/AzorTech Base
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827), // Dark Background
        primaryColor: const Color(0xFF2EA063), // AzorTech Green
        
        // CORREÇÃO AQUI: Definimos as cores pelo ColorScheme (Padrão Material 3)
        // Isso evita o erro de "CardThemeData" e define a cor dos Cards automaticamente.
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2EA063),
          surface: Color(0xFF1F2937), // Essa cor será usada pelos Cards
          onSurface: Colors.white,
        ),

        // Configuração Global de Fontes
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        
        // Ajustes finos de componentes
        dividerTheme: const DividerThemeData(color: Colors.white10),
      ),
      
      // Fluxo Inicial Seguro
      home: const LoginPage(),
    );
  }
}