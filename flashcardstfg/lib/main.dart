import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Variable que escucha el estado de la apliación, avisa si hay algún cambio
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
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

    // ValueListenableBuilder escucha la variable y reconstruye la app si cambia
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Flashcards TFG',
          debugShowCheckedModeBanner: false,
          
          // Le decimos a Flutter cómo es el tema claro y cómo es el oscuro
          theme: ThemeData.light(useMaterial3: true), // Tema claro por defecto
          darkTheme: ThemeData.dark(useMaterial3: true), // Tema oscuro por defecto
          
          // Le pasamos el modo actual (claro u oscuro)
          themeMode: currentMode,
          
          home: const LoginScreen(), // O tu auth wrapper si lo tienes
        );
      },
    );
  }
}
