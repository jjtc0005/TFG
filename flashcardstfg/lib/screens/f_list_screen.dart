import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardsListScreen extends StatelessWidget {
  final String carpetaId;
  final String mazoId;
  final String tituloMazo;

  const FlashcardsListScreen({
    super.key,
    required this.carpetaId,
    required this.mazoId,
    required this.tituloMazo,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(tituloMazo)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Carpetas')
            .doc(carpetaId)
            .collection('Mazos')
            .doc(mazoId)
            .collection('Flashcards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay tarjetas en este mazo.'));
          }

          final flashcards = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final data = flashcards[index].data() as Map<String, dynamic>;
              final pregunta = data['pregunta'] ?? '';
              final respuesta = data['respuesta'] ?? '';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P: $pregunta',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      Text(
                        'R: $respuesta',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
