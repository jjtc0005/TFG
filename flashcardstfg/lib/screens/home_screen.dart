import 'package:flashcardstfg/widgets/header_saludo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'create_flashcard_screen.dart';
import 'login_screen.dart';
import 'package:flashcardstfg/widgets/carpeta_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Apuntes'),
        centerTitle: true,
        // Tu botón de salir a la izquierda con aviso
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog( 
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Seguro que quieres salir?'),
                  actions: [
                    TextButton(
                      // Usamos dialogContext para cerrar la ventana
                      onPressed: () => Navigator.pop(dialogContext), 
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        // 1. Cerramos la ventana emergente
                        Navigator.pop(dialogContext); 
                        
                        // 2. Viajamos al Login usando el 'context' ORIGINAL de la HomeScreen
                        _cerrarSesion(context); 
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sí, salir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. PIEZA EXTRAÍDA: Saludo
          HeaderSaludo(user: user),

          const Divider(),

          // 2. Título corto
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

          // 3. LA CUADRÍCULA DE FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('Carpetas')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  // Si el usuario ya es null (se está cerrando sesión), no mostramos el error feo rojo
                  if (FirebaseAuth.instance.currentUser == null) {
                    return const Center(child: CircularProgressIndicator()); 
                  }
                  return Center(child: Text('Error: ${snapshot.error}'));
                }   
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
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final carpetas = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: carpetas.length,
                  itemBuilder: (context, index) {
                    final carpeta = carpetas[index];

                    // 4. PIEZA EXTRAÍDA: La tarjeta individual
                    return CarpetaCard(
                      idCarpeta: carpeta.id,
                      nombreCarpeta: carpeta['Nombre'] ?? 'Sin nombre',
                      // Conectamos la señal de editar
                      onEdit: () {
                        _editarCarpeta(context, carpeta.id, carpeta['Nombre'] ?? 'Sin nombre');
                      },
                      // Conectamos la señal de borrar
                      onDelete: () {
                        _borrarCarpeta(context, carpeta.id, carpeta['Nombre'] ?? 'Sin nombre');   
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // BOTÓN FLOTANTE
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateFlashcardScreen(),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Crear Mazo'),
      ),
    );
  }

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

// --- FUNCIÓN PARA EDITAR EL NOMBRE DE UNA CARPETA (NUEVA) ---
  Future<void> _editarCarpeta(BuildContext context, String carpetaId, String nombreActual) async {
    // Creamos un controlador para el texto y le ponemos el nombre que ya tiene
    final TextEditingController controladorNombre = TextEditingController(text: nombreActual);

    // Mostramos el diálogo para editar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre del mazo'),
        content: TextField(
          controller: controladorNombre,
          decoration: const InputDecoration(
            labelText: 'Nombre del mazo',
            border: OutlineInputBorder(),
          ),
          autofocus: true, // Para que el teclado salga solo
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancelar
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirmar
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    // Si el usuario cancela o no escribe nada nuevo, no hacemos nada
    if (confirmar != true || controladorNombre.text.isEmpty || controladorNombre.text == nombreActual) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      // Actualizamos el nombre en Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId)
          .update({
            'Nombre': controladorNombre.text, // El nuevo nombre
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error al editar la carpeta: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar el nombre'), backgroundColor: Colors.red),
        );
      }
    }
  }
 // --- FUNCIÓN PARA BORRAR CARPETA Y SUS TARJETAS ---
  Future<void> _borrarCarpeta(BuildContext context, String carpetaId, String nombreCarpeta) async {
    // 1. Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar mazo de flashcards?'),
        content: const Text('Se perderán todas las tarjetas que contenga permanentemente y no podrás recuperarlas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // --- EL TRUCO MAESTRO ---
    // Guardamos el "controlador de pantallas" y el "controlador de mensajes" 
    // antes de que la tarjeta se borre de Firebase y muera su context.
    final navegador = Navigator.of(context);
    final mensajes = ScaffoldMessenger.of(context);

    // Mostramos la pantalla de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final user = FirebaseAuth.instance.currentUser;
      final carpetaRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId);

      final flashcardsSnapshot = await carpetaRef.collection('Flashcards').get();
      for (var doc in flashcardsSnapshot.docs) {
        await doc.reference.delete();
      }

      await carpetaRef.delete();

      // Usamos las variables que guardamos arriba, así no importa que la tarjeta ya no exista
      navegador.pop(); // Quitamos el circulito
      mensajes.showSnackBar(
        const SnackBar(content: Text('Mazo borrado correctamente'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Error al borrar la carpeta: $e");
      
      // Si hay error, también quitamos el circulito con seguridad
      navegador.pop();
      mensajes.showSnackBar(
        const SnackBar(content: Text('Error al borrar el mazo'), backgroundColor: Colors.red),
      );
    }
  }
}
