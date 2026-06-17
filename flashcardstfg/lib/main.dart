ggitimport 'package:flashcardstfg/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
// 1. IMPORT ARREGLADO: Ruta oficial del generador de Flutter

// Variable que escucha el estado del tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Variable que escucha el estado del idioma (por defecto español)
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('es'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la sesión con la base de datos Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: "./apiKey.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. PRIMER ESCUCHADOR: Vigila si el usuario cambia a Modo Oscuro/Claro
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {

        // 3. SEGUNDO ESCUCHADOR: Vigila si el usuario cambia de Idioma
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, localeActual, _) {
            
            return MaterialApp(
              title: 'Flashcards TFG',
              debugShowCheckedModeBanner: false,

              // Le inyectamos el idioma detectado en el segundo escuchador
              locale: localeActual, 
              
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es', ''), // Español
                Locale('en', ''), // Inglés
              ],
              
              theme: ThemeData.light(useMaterial3: true),
              darkTheme: ThemeData.dark(useMaterial3: true),
              
              // Le inyectamos el tema detectado en el primer escuchador
              themeMode: currentMode,
              
              home: const LoginScreen(), 
            );
          },
        );
      },
    );
  }
}