import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono o Logo (Usamos uno de Flutter por ahora)
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

            // Botón de Login falso (solo visual)
            ElevatedButton.icon(
              onPressed: () {
                // Aquí pondremos la lógica de Google más tarde
                print("Botón pulsado");
              },
              icon: const Icon(Icons.login),
              label: const Text('Entrar con Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
