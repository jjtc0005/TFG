import 'package:flashcardstfg/screens/create_flashcard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para saber quién es el usuario
import '../services/auth_services.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual que acaba de iniciar sesión
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // 1. Barra Superior
      appBar: AppBar(
        title: const Text('Mis Apuntes'),
        centerTitle: true, // Centra el título
        actions: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // 1. Cerramos sesión en Firebase y Google
              await AuthService().signOut();

              // 2. Volvemos a la pantalla de Login
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      // 2. Cuerpo de la pantalla
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto de perfil (si tiene)
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            const SizedBox(height: 20),

            // Saludo con el nombre
            Text(
              '¡Hola, ${user?.displayName ?? 'Estudiante'}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              'Bienvenido a tu zona de estudio',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),

      // 3. Botón flotante (para añadir mazos en el futuro)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateFlashcardScreen(),
              ),
            );
          }
          print("Botón Crear pulsado");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
