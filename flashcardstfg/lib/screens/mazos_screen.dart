import 'package:flashcardstfg/screens/Flashcardslistscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MazosScreen extends StatelessWidget {
  final String carpetaId;
  final String nombreCarpeta;

  const MazosScreen({
    super.key,
    required this.carpetaId,
    required this.nombreCarpeta,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carpeta: $nombreCarpeta'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Buscamos todas las flashcards dentro de esta carpeta
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Carpetas')
            .doc(carpetaId)
            .collection('Flashcards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay mazos en esta carpeta.'));
          }

          // 1. Extraemos los títulos únicos usando un Set (para que no haya duplicados)
          Set<String> titulosUnicos = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['titulo_mazo'] ?? 'Sin título';
            titulosUnicos.add(titulo);
          }

          // Convertimos el Set a Lista para poder pintarlo
          List<String> listaMazos = titulosUnicos.toList();

          // 2. Pintamos la lista de Mazos
          return ListView.builder(
            itemCount: listaMazos.length,
            itemBuilder: (context, index) {
              final tituloMazo = listaMazos[index];
              
              // Opcional: Contar cuántas tarjetas tiene este mazo en concreto
              final int cantidadTarjetas = snapshot.data!.docs.where(
                (doc) => (doc.data() as Map<String, dynamic>)['titulo_mazo'] == tituloMazo
              ).length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.style, color: Colors.blue),
                  title: Text(
                    tituloMazo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$cantidadTarjetas tarjetas'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Al clicar, vamos a la pantalla de las tarjetas de este mazo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardsListScreen(
                          carpetaId: carpetaId,
                          tituloMazo: tituloMazo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}