import 'package:flashcardstfg/l10n/app_localizations.dart';
import 'package:flashcardstfg/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'create_f_screen.dart';
import 'login_screen.dart';
import 'package:flashcardstfg/widgets/carpeta_card.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        // Le sumamos los 20 píxeles de espacio que vamos a darle por arriba.
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 20,
        ), // kToolbarHeight es la altura estándar del AppBar en Flutter (suele ser 56.0).
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            title: Text(AppLocalizations.of(context)!.tituloHome),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: AppLocalizations.of(context)!.cerrarSesion,
              onPressed: () => _mostrarDialogoCerrarSesion(context),
            ),

            // El actions muestra en la pantalla todo empezando por la derecha
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                tooltip: AppLocalizations.of(context)!.configuracion,
                onSelected: (value) {
                  if (value == 'theme') {
                    // Modo oscuro / claro original
                    themeNotifier.value = themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  } else {
                    // Si el valor no es 'theme', es el código del idioma ('es', 'en', 'pt')
                    localeNotifier.value = Locale(value);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  // 1. Botón de Modo Oscuro/Claro
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          themeNotifier.value == ThemeMode.light
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.modoColor),
                      ],
                    ),
                  ),

                  // 2. Separador visual
                  const PopupMenuDivider(),

                  // 3. Opciones de idiomas
                  const PopupMenuItem<String>(
                    value: 'es',
                    child: Row(
                      children: [
                        Text('🇪🇸'),
                        SizedBox(width: 12),
                        Text('Español'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Text('🇬🇧'),
                        SizedBox(width: 12),
                        Text('English'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'pt',
                    child: Row(
                      children: [
                        Text('🇵🇹'),
                        SizedBox(width: 12),
                        Text('Português'),
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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.tusMazos,
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
                        Text(
                          AppLocalizations.of(context)!.errorMazos,
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
                        _editarCarpeta(
                          context,
                          carpeta.id,
                          carpeta['Nombre'] ?? 'Sin nombre',
                        );
                      },
                      onDelete: () {
                        _borrarCarpeta(
                          context,
                          carpeta.id,
                          carpeta['Nombre'] ?? 'Sin nombre',
                        );
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
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateFlashcardScreen(),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: Text(AppLocalizations.of(context)!.crearMazo),
      ),
      */
      floatingActionButton: SpeedDial(
        icon: Icons.add, // Icono principal cuando está cerrado
        activeIcon: Icons.close, // Icono cuando se abre el menú
        spacing: 3,
        spaceBetweenChildren: 4,
        tooltip: 'Crear contenido',
        children: [
          SpeedDialChild(
            child: const Icon(Icons.folder_open),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Nueva Carpeta',
            onTap: () {
              // Aquí llamaremos al diálogo para crear SOLO la carpeta
              _mostrarDialogoCrearCarpeta(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.flash_on),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Creación Rápida',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateFlashcardScreen(),
                ),
              );
            },
          ),
        ],
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
        print("${AppLocalizations.of(context)!.errorCerrarS} $e");
      }
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("${AppLocalizations.of(context)!.errorGeneralsesion} $e");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _mostrarDialogoCrearCarpeta(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Carpeta'),
          content: TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              hintText: 'Ej: Matemáticas, Historia...',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Botón cancelar
              child: const Text('Cancelar'),
            ),
FilledButton(
  onPressed: () async {
    // 1. Comprobamos que el texto no esté vacío
    if (nombreController.text.trim().isNotEmpty) {
      
      // 2. Obtenemos el usuario que está logueado actualmente
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        try {
          // 3. Creamos el documento en la ruta exacta de tu base de datos
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('Carpetas')
              .add({
            'Nombre': nombreController.text.trim(), 
            'fechaCreacion': FieldValue.serverTimestamp(),
            // Si en tu modelo de BD guardas la fecha, puedes añadirla aquí, ej:
            // 'fechaCreacion': FieldValue.serverTimestamp(),
          });

          // 4. Cerramos el diálogo solo si ha ido bien
          if (context.mounted) {
            Navigator.pop(context); 
          }
          
        } catch (e) {
          // (Opcional) Mostrar un mensajito de error si falla la conexión
          print("Error al crear la carpeta: $e");
        }
      }
    }
  },
  child: const Text('Crear'),
),
          ],
        );
      },
    );
  }

  Future<void> _editarCarpeta(
    BuildContext context,
    String carpetaId,
    String nombreActual,
  ) async {
    final TextEditingController controladorNombre = TextEditingController(
      text: nombreActual,
    );

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.mensajeEditar),
        content: TextField(
          controller: controladorNombre,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.nombreMazo,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.guardar),
          ),
        ],
      ),
    );

    if (confirmar != true ||
        controladorNombre.text.isEmpty ||
        controladorNombre.text == nombreActual)
      return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Carpetas')
          .doc(carpetaId)
          .update({'Nombre': controladorNombre.text});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.nombreEditado),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("${AppLocalizations.of(context)!.errorEditar} $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorEditar),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _borrarCarpeta(
    BuildContext context,
    String carpetaId,
    String nombreCarpeta,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.borrarCarpeta),
        content: Text(AppLocalizations.of(context)!.avisoBorrar),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.borrar),
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

      // 1. Instanciamos el batch
      final batch = FirebaseFirestore.instance.batch();

      // Petición de lectura de los mazos (Requiere red)
      final mazosSnapshot = await carpetaRef.collection('Mazos').get();

      for (var mazoDoc in mazosSnapshot.docs) {
        // Petición de lectura de las flashcards del mazo (Requiere red)
        final flashcardsSnapshot = await mazoDoc.reference
            .collection('Flashcards')
            .get();

        // Encolado iterativo de la destrucción de tarjetas
        for (var cardDoc in flashcardsSnapshot.docs) {
          batch.delete(cardDoc.reference);
        }

        // Encolado de la destrucción del documento del mazo
        batch.delete(mazoDoc.reference);
      }

      // Encolado de la destrucción del documento raíz de la carpeta
      batch.delete(carpetaRef);

      // 6. Ejecutamos todas las eliminaciones de golpe
      await batch.commit();

      navegador.pop();
      mensajes.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.confirmadoBorrado),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("${AppLocalizations.of(context)!.errorBorrar} $e");
      navegador.pop();
      mensajes.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorBorrar),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cerrarSesion),
        content: Text(AppLocalizations.of(context)!.confirmacionSesion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancelar),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cerrarSesion(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.salir),
          ),
        ],
      ),
    );
  }
}
