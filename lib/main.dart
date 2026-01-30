import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/task_controller.dart';
import 'pages/login_page.dart'; // Ajuste o import se sua pasta for ui/pages ou pages

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
    // PALETA DEEP DARK (Sem Branco)
    const primaryColor = Color(0xFF2EA063);      // Verde Neon
    const bgColor = Color(0xFF0F172A);           // Fundo Profundo (Slate 900)
    const surfaceColor = Color(0xFF1E293B);      // Cards/Dialogs (Slate 800)
    const inputColor = Color(0xFF334155);        // Inputs (Slate 700)
    const borderColor = Color(0xFF475569);       // Bordas (Slate 600)
    const textColor = Color(0xFFF1F5F9);         // Texto Principal (Slate 100)
    const textSecColor = Color(0xFF94A3B8);      // Texto Secundário (Slate 400)

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
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
          background: bgColor,
          surface: surfaceColor,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: bgColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: textColor),
          titleTextStyle: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: borderColor)),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: borderColor)),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputColor,
          hintStyle: const TextStyle(color: textSecColor),
          labelStyle: const TextStyle(color: textSecColor),
          prefixIconColor: textSecColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryColor)),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),

        iconTheme: const IconThemeData(color: textSecColor),
        dividerTheme: const DividerThemeData(color: borderColor),
        
        popupMenuTheme: PopupMenuThemeData(
          color: surfaceColor,
          textStyle: GoogleFonts.inter(color: textColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: borderColor)),
        ),
      ),
      home: const LoginPage(),
    );
  }
}