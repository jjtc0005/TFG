import 'package:flutter/material.dart';
// IMPORTANTE: Asegúrate de que estos nombres coinciden con tus archivos reales
import '../services/auth_services.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            const Icon(Icons.school, size: 100, color: Colors.blue),
            const SizedBox(height: 20),

            // Título
            const Text(
              'Flashcards AI',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Tu estudio, potenciado por Gemini'),

            const SizedBox(height: 50),

            // BOTÓN REAL CONECTADO
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar con Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              // Aquí está la magia:
              onPressed: () async {
                print("Botón pulsado. Iniciando login...");

                // 1. Llamamos a tu servicio (que ya arreglamos)
                final userCredential = await AuthService().signInWithGoogle();

                // 2. Comprobamos si salió bien
                if (userCredential != null) {
                  print("Login Éxito: ${userCredential.user?.displayName}");

                  // 3. NAVEGACIÓN: Cambiamos de pantalla
                  // El 'if (context.mounted)' es vital en Flutter moderno para evitar errores
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

                  // Opcional: Mostrar un aviso al usuario si falló
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No se pudo iniciar sesión"),
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