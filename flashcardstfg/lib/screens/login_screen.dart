import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';

// 1. Cambiamos a StatefulWidget para poder actualizar la pantalla en tiempo real
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. Variable para controlar el estado de carga
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

            // 3. Renderizado condicional: o la rueda, o el botón
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
                      // 4. Encendemos la rueda de carga antes de hablar con Google
                      setState(() {
                        _isLoading = true;
                      });
                      
                      print("Botón pulsado. Iniciando login...");
                      final userCredential = await AuthService().signInWithGoogle();

                      if (userCredential != null) {
                        print("Login Éxito: ${userCredential.user?.displayName}");
                        // No hace falta poner _isLoading = false porque cambiamos de pantalla
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
                        
                        // 5. Si falla o cancela, apagamos la rueda para que vuelva a salir el botón
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