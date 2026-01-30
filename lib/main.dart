import 'package:azt_tasks/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/task_controller.dart';
import 'pages/login_page.dart';

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
    // --- PALETA DE CORES DARK MODE DEFINITIVA ---
    const primaryColor = Color(0xFF2EA063);      // Verde AZT
    const bgColor = Color(0xFF0B0F19);           // Fundo da Tela (Quase preto)
    const surfaceColor = Color(0xFF151B2B);      // Cards e Dialogs (Cinza Azulado Escuro)
    const inputColor = Color(0xFF1F2937);        // Fundo dos Inputs
    const borderColor = Color(0xFF2D3748);       // Bordas sutis
    const textColor = Color(0xFFF3F4F6);         // Branco Gelo (Leitura)
    const textSecColor = Color(0xFF9CA3AF);      // Cinza Texto Secundário

    // Tipografia Global
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
        scaffoldBackgroundColor: bgColor,
        textTheme: textTheme,
        primaryColor: primaryColor,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
          surface: surfaceColor,
          background: bgColor,
        ),

        // APP BAR GLOBAL
        appBarTheme: AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: textColor),
          titleTextStyle: GoogleFonts.inter(
            color: textColor, fontWeight: FontWeight.bold, fontSize: 20
          ),
        ),

        // CARDS (Removemos o branco daqui)
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderColor),
          ),
        ),

        // DIALOGS / MODAIS
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent, // Remove tint rosa do Material 3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
        ),

        // INPUTS (TEXTFIELDS)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputColor, // Fundo escuro para digitar
          hintStyle: const TextStyle(color: textSecColor),
          labelStyle: const TextStyle(color: textSecColor),
          contentPadding: const EdgeInsets.all(16),
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
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),

        // BOTÕES
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        
        // ÍCONES
        iconTheme: const IconThemeData(color: textSecColor),
        
        // MENUS
        popupMenuTheme: PopupMenuThemeData(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: borderColor),
          ),
          textStyle: GoogleFonts.inter(color: textColor),
        ),
        
        dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      ),
      home: const LoginPage(),
    );
  }
}