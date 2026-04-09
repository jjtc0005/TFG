import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcardstfg/screens/flashcard_animada.dart';


class StudyScreen extends StatelessWidget {
  final String carpetaId;
  final String nombreCarpeta;

  const StudyScreen({
    super.key,
    required this.carpetaId,
    required this.nombreCarpeta,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(nombreCarpeta), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Carpetas')
            .doc(carpetaId)
            .collection('Mazos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Esta carpeta está vacía.\n¡Crea algunos mazos!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final listaMazos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaMazos.length,
            itemBuilder: (context, index) {
              final docMazo = listaMazos[index];
              final data = docMazo.data() as Map<String, dynamic>;

              final tituloMazo = data['titulo'] ?? 'Sin título';
              final cantidadTarjetas = data['cantidad_tarjetas'] ?? 0;
              final mazoId = docMazo
                  .id; // Necesitamos este ID para luego buscar sus tarjetas

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.style, color: Colors.blue),
                  ),
                  title: Text(
                    tituloMazo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '$cantidadTarjetas tarjetas',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_fill,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MazoStudyScreen(
                          carpetaId: carpetaId,
                          mazoId: mazoId,
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


class MazoStudyScreen extends StatefulWidget {
  final String carpetaId;
  final String mazoId;
  final String tituloMazo;

  const MazoStudyScreen({
    super.key,
    required this.carpetaId,
    required this.mazoId,
    required this.tituloMazo,
  });

  @override
  State<MazoStudyScreen> createState() => _MazoStudyScreenState();
}

class _MazoStudyScreenState extends State<MazoStudyScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _tarjetaActual = ValueNotifier<int>(1);
  late Stream<QuerySnapshot> _streamTarjetas;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _streamTarjetas = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Carpetas')
        .doc(widget.carpetaId)
        .collection('Mazos')
        .doc(widget.mazoId)
        .collection('Flashcards')
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tarjetaActual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.tituloMazo),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _streamTarjetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay tarjetas en este mazo.'));
          }

          final flashcards = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: _tarjetaActual,
                  builder: (context, valorActual, child) {
                    return Text(
                      'Tarjeta $valorActual de ${flashcards.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    _tarjetaActual.value = index + 1;
                  },
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final data =
                        flashcards[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FlashcardAnimada(
                        key: ValueKey(flashcards[index].id),
                        pregunta: data['pregunta'] ?? 'Sin pregunta',
                        respuesta: data['respuesta'] ?? 'Sin respuesta',
                      ),
                    );
                  },
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  '👈 Desliza para cambiar | Toca para girar 👆',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
