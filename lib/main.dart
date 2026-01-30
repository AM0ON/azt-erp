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
    // PALETA DARK MODE
    const primaryColor = Color(0xFF2EA063); // Verde AZT (Mantido)
    const backgroundColor = Color(0xFF111827); // Fundo Principal (Rich Black)
    const surfaceColor = Color(0xFF1F2937); // Cards e Dialogs (Dark Grey)
    const textColor = Color(0xFFF9FAFB); // Texto Principal (Off-white)
    const textSecColor = Color(0xFF9CA3AF); // Texto Secundário (Cool Grey)
    const borderColor = Color(0xFF374151); // Bordas Sutis

    // Configuração da Fonte (Inter para tudo, cor branca padrão)
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
      
      // TEMA ESCURO GLOBAL
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Importante para o Flutter ajustar contraste nativo
        scaffoldBackgroundColor: backgroundColor,
        textTheme: textTheme,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
          background: backgroundColor,
          surface: surfaceColor,
        ),
        
        // AppBar Escura
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

        // Cards e Dialogs
        cardTheme: CardTheme(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderColor),
          ),
        ),

        dialogTheme: DialogTheme(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
        ),

        // Botões
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

        // Inputs (Campos de Texto Escuros)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF374151), // Cinza mais claro que o fundo
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(color: textSecColor),
          labelStyle: TextStyle(color: textSecColor),
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

        // Menu Popup
        popupMenuTheme: PopupMenuThemeData(
          color: surfaceColor,
          textStyle: GoogleFonts.inter(color: textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
            side: const BorderSide(color: borderColor)
          ),
        ),
        
        // Divisores
        dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      ),
      home: const LoginPage(),
    );
  }
}