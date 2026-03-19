import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// =========================================================================
// PANTALLA 1: MUESTRA LOS MAZOS DENTRO DE LA CARPETA (EL ÍNDICE)
// =========================================================================
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
      appBar: AppBar(
        title: Text(nombreCarpeta),
        centerTitle: true,
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
                'Esta carpeta está vacía.\n¡Crea algunas flashcards con IA!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // Extraemos los nombres de los mazos sin que se repitan
          Set<String> titulosUnicos = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['titulo_mazo'] ?? 'Sin título';
            titulosUnicos.add(titulo);
          }

          List<String> listaMazos = titulosUnicos.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaMazos.length,
            itemBuilder: (context, index) {
              final tituloMazo = listaMazos[index];

              // Contamos cuántas tarjetas tiene este mazo en concreto
              final int cantidadTarjetas = snapshot.data!.docs.where(
                (doc) => (doc.data() as Map<String, dynamic>)['titulo_mazo'] == tituloMazo
              ).length;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.style, color: Colors.blue),
                  ),
                  title: Text(
                    tituloMazo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    '$cantidadTarjetas tarjetas',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: const Icon(Icons.play_circle_fill, size: 30, color: Colors.blueAccent),
                  onTap: () {
                    // Al tocar, abrimos el carrusel de estudio
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MazoStudyScreen(
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

// =========================================================================
// PANTALLA 2: MODO ESTUDIO (CARRUSEL DESLIZABLE)
// =========================================================================
class MazoStudyScreen extends StatefulWidget {
  final String carpetaId;
  final String tituloMazo;

  const MazoStudyScreen({
    super.key,
    required this.carpetaId,
    required this.tituloMazo,
  });

  @override
  State<MazoStudyScreen> createState() => _MazoStudyScreenState();
}

class _MazoStudyScreenState extends State<MazoStudyScreen> {
  final PageController _pageController = PageController();
  int _tarjetaActual = 1;
  late Stream<QuerySnapshot> _streamTarjetas;

  @override
  void initState() {
    super.initState();
    // Cargamos las tarjetas de este mazo específico
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _streamTarjetas = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Carpetas')
        .doc(widget.carpetaId)
        .collection('Flashcards')
        .where('titulo_mazo', isEqualTo: widget.tituloMazo)
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
              // Contador de tarjetas superior
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Tarjeta $_tarjetaActual de ${flashcards.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ),

              // Carrusel de tarjetas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _tarjetaActual = index + 1;
                    });
                  },
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final data = flashcards[index].data() as Map<String, dynamic>;
                    final pregunta = data['pregunta'] ?? 'Sin pregunta';
                    final respuesta = data['respuesta'] ?? 'Sin respuesta';
                    final idTarjeta = flashcards[index].id;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FlashcardAnimada(
                        key: ValueKey(idTarjeta),
                        pregunta: pregunta,
                        respuesta: respuesta,
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
              )
            ],
          );
        },
      ),
    );
  }
}

// =========================================================================
// WIDGET 3: LA TARJETA ANIMADA EN 3D
// =========================================================================
class FlashcardAnimada extends StatefulWidget {
  final String pregunta;
  final String respuesta;

  const FlashcardAnimada({
    super.key,
    required this.pregunta,
    required this.respuesta,
  });

  @override
  State<FlashcardAnimada> createState() => _FlashcardAnimadaState();
}

class _FlashcardAnimadaState extends State<FlashcardAnimada> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _esFrente = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _esFrente = _controller.value < 0.5;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _voltearTarjeta() {
    if (_esFrente) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _voltearTarjeta,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final anguloRadianes = _animation.value * pi;
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(anguloRadianes),
            alignment: Alignment.center,
            child: _esFrente
                ? _construirLadoTarjeta(
                    texto: widget.pregunta,
                    colorFondo: Colors.white,
                    colorTexto: Colors.blue.shade900,
                    etiqueta: 'PREGUNTA',
                    icono: Icons.help_outline,
                  )
                : Transform.scale(
                    scaleX: -1,
                    child: _construirLadoTarjeta(
                        texto: widget.respuesta,
                        colorFondo: Colors.green.shade50,
                        colorTexto: Colors.green.shade900,
                        etiqueta: 'RESPUESTA',
                        icono: Icons.check_circle_outline,
                      ),
                  ),
          );
        },
      ),
    );
  }

  Widget _construirLadoTarjeta({
    required String texto,
    required Color colorFondo,
    required Color colorTexto,
    required String etiqueta,
    required IconData icono,
  }) {
    return Card(
      color: colorFondo,
      elevation: 12,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: 20, color: Colors.blueGrey.shade300),
                const SizedBox(width: 8),
                Text(
                  etiqueta,
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: colorTexto,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              'Toca para voltear',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}