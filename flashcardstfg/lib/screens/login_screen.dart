import 'package:flashcardstfg/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Variable para controlar el estado de carga
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.blue),
            const SizedBox(height: 20),

            const Text(
              'Flashcards AI',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.mensajeLogin),

            const SizedBox(height: 50),

            // 2. Botón circular mientras inicia sesión con Google
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(AppLocalizations.of(context)!.mensajeEntrarGoogle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      ),
                      elevation: isDarkMode ? 0 : 2, // En modo oscuro queda mejor sin sombra (0)
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // 3. Activamos el estado de carga
                      setState(() {
                        _isLoading = true;
                      });
                      
                      print("${AppLocalizations.of(context)!.botonPulsadoLogin} ");
                      final userCredential = await AuthService().signInWithGoogle();

                      if (userCredential != null) {
                        print("Login Éxito: ${userCredential.user?.displayName}");

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      } else {
                        print("Login fallido o cancelado");
                        
                        // 4. Si falla o cancela el inicio cambiamos al estado inicial
                        setState(() {
                          _isLoading = false;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.errorSesion),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}