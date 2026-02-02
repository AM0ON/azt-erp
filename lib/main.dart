import 'package:azt_tasks/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// IMPORTS DOS CONTROLLERS (Confira se as pastas batem)
import 'controllers/task_controller.dart';
import 'controllers/finance_controller.dart';
import 'controllers/client_controller.dart'; // <--- IMPORTANTE

// IMPORTS DAS PAGES
import 'ui/pages/hub_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        // O TaskController que já tínhamos
        ChangeNotifierProvider(create: (_) => TaskController()),
        
        // O FinanceController (se já tiver criado)
        ChangeNotifierProvider(create: (_) => FinanceController()),

        // --- A CORREÇÃO DO ERRO ESTÁ AQUI: ---
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
      title: 'AzorTech Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        primaryColor: const Color(0xFF2EA063),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}