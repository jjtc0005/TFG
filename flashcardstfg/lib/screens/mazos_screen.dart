import 'package:flashcardstfg/widgets/mazo_card.dart';
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
            return const Center(
              child: Text(
                'No hay mazos en esta carpeta.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 1. Extraemos los títulos únicos usando un Set
          Set<String> titulosUnicos = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['titulo_mazo'] ?? 'Sin título';
            titulosUnicos.add(titulo);
          }

          List<String> listaMazos = titulosUnicos.toList();

          // 2. Pintamos la lista usando nuestro nuevo Widget modular
          return ListView.builder(
            itemCount: listaMazos.length,
            itemBuilder: (context, index) {
              final tituloMazo = listaMazos[index];
              
              // Contar cuántas tarjetas tiene este mazo
              final int cantidadTarjetas = snapshot.data!.docs.where(
                (doc) => (doc.data() as Map<String, dynamic>)['titulo_mazo'] == tituloMazo
              ).length;

              // Usamos la pieza de Lego que hemos extraído
              return MazoCard(
                tituloMazo: tituloMazo,
                cantidadTarjetas: cantidadTarjetas,
                carpetaId: carpetaId,
              );
            },
          );
        },
      ),
    );
  }
}