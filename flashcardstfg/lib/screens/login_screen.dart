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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
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