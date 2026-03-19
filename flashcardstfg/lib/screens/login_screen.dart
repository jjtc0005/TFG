import 'package:flutter/material.dart';
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

            // Botón para entrar con Google

            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar con Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () async {
                print("Botón pulsado. Iniciando login...");

                // 1. Llamamos al servicio que inicia sesion con google
                final userCredential = await AuthService().signInWithGoogle();

                // 2. Comprobamos si el login se completó
                if (userCredential != null) {
                  print("Login Éxito: ${userCredential.user?.displayName}");

                // 3. Cambiamos de pantalla una vez iniciada la sesión a la ventana principal 
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