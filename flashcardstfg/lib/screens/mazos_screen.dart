import 'package:flashcardstfg/widgets/mazo_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MazosScreen extends StatelessWidget {
  final String carpetaId;
  final String nombreCarpeta;
  // ELIMINAMOS mazoId de aquí. Esta pantalla muestra MUCHOS mazos, no uno solo.

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
            .collection('Mazos') // ¡Perfecto! Apuntamos a los Mazos
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

          // 1. Ya no hay Sets ni for loops. 
          // La lista de mazos es directamente la lista de documentos que nos da Firebase
          final listaMazos = snapshot.data!.docs;

          // 2. Pintamos la lista
          return ListView.builder(
            itemCount: listaMazos.length,
            itemBuilder: (context, index) {
              
              // Sacamos el documento del mazo actual de la lista
              final docMazo = listaMazos[index];
              final data = docMazo.data() as Map<String, dynamic>;
              
              // Extraemos los datos que guardamos cuando creamos el mazo
              final tituloMazo = data['titulo'] ?? 'Sin título';
              final int cantidadTarjetas = data['cantidad_tarjetas'] ?? 0;
              
              // ¡AQUÍ ESTÁ LA CLAVE! Sacamos el mazoId directamente del documento de Firebase
              final String elMazoId = docMazo.id; 

              // Usamos la pieza de Lego
              return MazoCard(
                tituloMazo: tituloMazo,
                cantidadTarjetas: cantidadTarjetas,
                mazoId: elMazoId, // Se lo pasamos a la tarjeta
                carpetaId: carpetaId,
              );
            },
          );
        },
      ),
    );
  }
}