import 'package:flashcardstfg/l10n/app_localizations.dart';
import 'package:flashcardstfg/main.dart';
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
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
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
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                tooltip: AppLocalizations.of(context)!.configuracion,
                onSelected: (value) {
                  if (value == 'theme') {
                    themeNotifier.value = themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  } else {
                    localeNotifier.value = Locale(value);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  const PopupMenuDivider(),
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

      // --- MODIFICADO: Botón flotante clásico que despliega el menú ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarPanelCreacion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarPanelCreacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 40,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barrita superior visual (deslizar)
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Título central
              Text(
                AppLocalizations.of(context)!.queDeseasCrear,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Fila con los dos botones grandes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BOTÓN 1: CARPETA VACÍA ---
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _mostrarDialogoCrearCarpeta(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            // Fondo azul translúcido que combina con la carpeta
                            backgroundColor: Colors.blue.withOpacity(0.15),
                            child: const Icon(
                              Icons.folder_open,
                              size: 35,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.carpetaVaciaBoton,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- BOTÓN 2: MAZO CON IA (TOTALMENTE ARMONIZADO) ---
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateFlashcardScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            // Fondo ámbar translúcido que combina con la estrella
                            backgroundColor: Colors.amber.withOpacity(0.15),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 35,
                              color: Colors.amber, // Estrella ámbar brillante
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.mazoRapidoBoton,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  // --- FIN DEL AÑADIDO ---

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
          title: Text(AppLocalizations.of(context)!.nuevaCarpeta),
          content: TextField(
            controller: nombreController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.ejemploCarpeta,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            FilledButton(
              onPressed: () async {
                if (nombreController.text.trim().isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('Carpetas')
                          .add({
                            'Nombre': nombreController.text.trim(),
                            'fechaCreacion': FieldValue.serverTimestamp(),
                          });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print("Error al crear la carpeta: $e");
                    }
                  }
                }
              },
            child: Text(AppLocalizations.of(context)!.crear),            ),
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
        controladorNombre.text == nombreActual) {
      return;
    }

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

      final batch = FirebaseFirestore.instance.batch();
      final mazosSnapshot = await carpetaRef.collection('Mazos').get();

      for (var mazoDoc in mazosSnapshot.docs) {
        final flashcardsSnapshot = await mazoDoc.reference
            .collection('Flashcards')
            .get();

        for (var cardDoc in flashcardsSnapshot.docs) {
          batch.delete(cardDoc.reference);
        }
        batch.delete(mazoDoc.reference);
      }

      batch.delete(carpetaRef);
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
