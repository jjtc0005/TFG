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
            const Text('Tu estudio, potenciado por Gemini'),

            const SizedBox(height: 50),

            // 2. Botón circular mientras inicia sesión con Google
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar con Google'),
                    style: ElevatedButton.styleFrom(
                  // CAMBIO DE COLOR DE FONDO
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      // CAMBIO DE COLOR DE TEXTO E ICONO
                      foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                      // ¡AQUÍ ESTÁ EL BORDE! Sí se puede en ElevatedButton
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
                      
                      print("Botón pulsado. Iniciando login...");
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
                            const SnackBar(
                              content: Text("No se pudo iniciar sesión"),
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