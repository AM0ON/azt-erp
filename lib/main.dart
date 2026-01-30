import 'package:azt_tasks/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/task_controller.dart';
import '../pages/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskController()),
      ],
      child: const AZTTasksApp(),
    ),
  );
}

class AZTTasksApp extends StatelessWidget {
  const AZTTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. DEFINIÇÃO DAS CORES (Variáveis locais)
    const primaryColor = Color(0xFF2EA063);
    const backgroundColor = Color(0xFF111827);
    const surfaceColor = Color(0xFF1F2937);
    const textColor = Color(0xFFF9FAFB);
    const textSecColor = Color(0xFF9CA3AF);
    const borderColor = Color(0xFF374151);

    // Configuração da Fonte
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return MaterialApp(
      title: 'AZT-Tasks',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: textTheme,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
          background: backgroundColor,
          surface: surfaceColor,
        ),
        
        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: textColor),
          titleTextStyle: GoogleFonts.inter(
            color: textColor, 
            fontSize: 20, 
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5
          ),
        ),

        // CORREÇÃO: CardTheme (minúsculo no início)
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderColor),
          ),
        ),

        // CORREÇÃO: DialogTheme (minúsculo no início)
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
        ),

        // CORREÇÃO CRÍTICA AQUI:
        // O nome do parâmetro é 'filledButtonTheme' (minúsculo)
        // O valor é 'FilledButtonThemeData' (Classe de dados)
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF374151),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: textSecColor),
          labelStyle: const TextStyle(color: textSecColor),
          prefixIconColor: textSecColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),

        // Menus
        popupMenuTheme: PopupMenuThemeData(
          color: surfaceColor,
          textStyle: GoogleFonts.inter(color: textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
            side: const BorderSide(color: borderColor)
          ),
        ),
        
        dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      ),
      home: const LoginPage(),
    );
  }
}