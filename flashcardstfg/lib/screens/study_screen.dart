import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyScreen extends StatefulWidget {
  final String carpetaId;
  final String nombreCarpeta;

  const StudyScreen({
    super.key,
    required this.carpetaId,
    required this.nombreCarpeta,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final PageController _pageController = PageController();
  bool _mostrarRespuesta = false;
  int _tarjetaActual = 1;

  // 1. Creamos una variable para guardar el "túnel" de datos
late Stream<QuerySnapshot<Map<String, dynamic>>> _tarjetasStream;

  @override
  void initState() {
    super.initState();
    // 2. Conectamos con Firebase UNA SOLA VEZ al abrir la pantalla
    final user = FirebaseAuth.instance.currentUser;
    _tarjetasStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Carpetas')
        .doc(widget.carpetaId)
        .collection('Flashcards')
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _girarTarjeta() {
    setState(() {
      _mostrarRespuesta = !_mostrarRespuesta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(widget.nombreCarpeta),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // 3. Usamos la variable guardada, así no se reinicia al hacer scroll
        stream: _tarjetasStream,
        builder: (context, snapshot) {
          
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las tarjetas.'));
          }

          // 4. Pequeña mejora: solo mostramos el círculo de carga si NO hay datos previos
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Esta carpeta no tiene tarjetas aún.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final tarjetas = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Tarjeta $_tarjetaActual de ${tarjetas.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: tarjetas.length,
                  onPageChanged: (index) {
                    setState(() {
                      _mostrarRespuesta = false; // Oculta la respuesta al pasar de tarjeta
                      _tarjetaActual = index + 1; // Actualiza el número
                    });
                  },
                  itemBuilder: (context, index) {
                    final tarjeta = tarjetas[index];
                    final pregunta = tarjeta['pregunta'] ?? 'Sin pregunta';
                    final respuesta = tarjeta['respuesta'] ?? 'Sin respuesta';

                    return GestureDetector(
                      onTap: _girarTarjeta,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: _mostrarRespuesta ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: _mostrarRespuesta ? Colors.green : Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _mostrarRespuesta ? '💡 Respuesta' : '❓ Pregunta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _mostrarRespuesta ? Colors.green : Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _mostrarRespuesta ? respuesta : pregunta,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Toca la tarjeta para voltear',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}