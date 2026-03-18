import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- AÑADIDO: Para leer la base de datos
import 'package:google_sign_in/google_sign_in.dart';
import 'create_flashcard_screen.dart';
import 'login_screen.dart';
import 'study_screen.dart'; // Asegúrate de que la ruta sea correcta

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Apuntes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. CABECERA CON SALUDO ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (user?.photoURL != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user!.photoURL!),
                  )
                else
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${user?.displayName?.split(' ').first ?? 'Estudiante'}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '¿Qué vamos a estudiar hoy?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // --- 2. TÍTULO DE LA SECCIÓN ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tus Mazos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- 3. CUADRÍCULA DE CARPETAS DESDE FIREBASE ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('Carpetas')
                  .snapshots(),
              builder: (context, snapshot) {
                // Mientras carga...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Si hay un error...
                if (snapshot.hasError) {
                  print(" ERROR DE FIREBASE: ${snapshot.error}"); // Nos lo chivará en la consola
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error de Firebase:\n${snapshot.error}', 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // Si no tiene carpetas aún...
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_off,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aún no tienes mazos.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          'Usa el botón + para crear uno con IA.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Si todo va bien, mostramos las carpetas
                final carpetas = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // Forma un poco más cuadrada
                  ),
                  itemCount: carpetas.length,
                  itemBuilder: (context, index) {
                    final carpeta = carpetas[index];
                    final nombreCarpeta = carpeta['Nombre'] ?? 'Sin nombre';
                    final idCarpeta = carpeta.id;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudyScreen(
                                carpetaId: idCarpeta,
                                nombreCarpeta: nombreCarpeta,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_special,
                                size: 48,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  nombreCarpeta,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow
                                      .ellipsis, // Pone "..." si el texto es muy largo
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 4. BOTÓN FLOTANTE
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateFlashcardScreen(),
              ),
            );
          }
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Crear Mazo'),
      ),
    );
  }

  // --- FUNCIÓN DE CERRAR SESIÓN (Ya perfecta) ---
  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn.instance;
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        print("Aviso al desconectar Google: $e");
      }
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("Error general cerrando sesión: $e");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  // --- FUNCIÓN PARA BORRAR CARPETA Y SUS TARJETAS ---
  
  Future<void> _borrarCarpeta(BuildContext context, String carpetaId, String nombreCarpeta) async {
    // 1. Mostramos un diálogo de confirmación (¡Buena práctica de UX!)
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar mazo?'),
        content: Text('¿Estás seguro de que quieres borrar "$nombreCarpeta"? Se perderán todas las tarjetas que contenga.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    // Si el usuario cancela, no hacemos nada
    if (confirmar != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final carpetaRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId);

      // 2. Primero buscamos y borramos todas las flashcards que hay dentro
      final flashcardsSnapshot = await carpetaRef.collection('Flashcards').get();
      for (var doc in flashcardsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3. Una vez vacía, borramos la carpeta
      await carpetaRef.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mazo borrado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error al borrar la carpeta: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al borrar el mazo'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
