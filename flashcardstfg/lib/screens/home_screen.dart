import 'package:flashcardstfg/widgets/header_saludo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'create_f_screen.dart';
import 'login_screen.dart';
import 'package:flashcardstfg/widgets/carpeta_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        
        // Le sumamos los 20 píxeles de espacio que vamos a darle por arriba.
        preferredSize: const Size.fromHeight(kToolbarHeight + 20), // kToolbarHeight es la altura estándar del AppBar en Flutter (suele ser 56.0). 
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0), // Este es el espacio por encima del AppBar 
          child: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white, // Fuerza el fondo blanco siempre
            title: const Text('Mis Apuntes'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Cerrar sesión',
              onPressed: () => _mostrarDialogoCerrarSesion(context),
            ),

        // El actions muestra en la pantalla todo empezando por la derecha
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onSelected: (value) {
              if (value == 'theme') {
                // TODO: Lógica del modo oscuro
                print("Botón de modo oscuro pulsado");
              } else if (value == 'language') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El cambio de idioma estará disponible próximamente.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Modo Oscuro / Claro'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'language',
                child: Row(
                  children: [
                    Icon(Icons.language, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Idioma (Próximamente)'),
                  ],
                ),
              ),
            ],
          ),
        ],
       ),
      ),
    ),
      body: Column(
        children: [

          // Ya no hay header, solo dividimos el AppBar con el resto de la aplicación con una línea
          const Divider(),

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

          // Lectura de Firebase
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

                    return CarpetaCard(
                      idCarpeta: carpeta.id,
                      nombreCarpeta: carpeta['Nombre'] ?? 'Sin nombre',
                      onEdit: () {
                        _editarCarpeta(context, carpeta.id, carpeta['Nombre'] ?? 'Sin nombre');
                      },
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

  Future<void> _editarCarpeta(BuildContext context, String carpetaId, String nombreActual) async {
    final TextEditingController controladorNombre = TextEditingController(text: nombreActual);

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
          autofocus: true, 
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmar != true || controladorNombre.text.isEmpty || controladorNombre.text == nombreActual) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId)
          .update({
            'Nombre': controladorNombre.text, 
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

  Future<void> _borrarCarpeta(BuildContext context, String carpetaId, String nombreCarpeta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar esta carpeta?'),
        content: const Text('Se perderán todos los mazos y tarjetas que contenga permanentemente. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, borrar TODO'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final navegador = Navigator.of(context);
    final mensajes = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final carpetaRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId);

      final mazosSnapshot = await carpetaRef.collection('Mazos').get();
      
      for (var mazoDoc in mazosSnapshot.docs) {
        final flashcardsSnapshot = await mazoDoc.reference.collection('Flashcards').get();
        for (var cardDoc in flashcardsSnapshot.docs) {
          await cardDoc.reference.delete(); 
        }
        await mazoDoc.reference.delete();
      }

      final oldFlashcards = await carpetaRef.collection('Flashcards').get();
      for (var doc in oldFlashcards.docs) {
        await doc.reference.delete();
      }

      await carpetaRef.delete();

      navegador.pop(); 
      mensajes.showSnackBar(
        const SnackBar(content: Text('Carpeta borrada limpiamente'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Error al borrar la carpeta: $e");
      navegador.pop();
      mensajes.showSnackBar(
        const SnackBar(content: Text('Error al borrar la carpeta'), backgroundColor: Colors.red),
      );
    }
  }
  
  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog( 
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); 
              _cerrarSesion(context); 
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, salir'),
          ),
        ],
      ),
    );
  }
}