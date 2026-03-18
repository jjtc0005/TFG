import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Importación necesaria para el cálculo del ángulo PI

// =========================================================================
// PANTALLA 1: MUESTRA LOS MAZOS DENTRO DE LA CARPETA (LISTA)
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
                'Esta carpeta está vacía.\n¡Crea algunas flashcards!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // Extraemos los "titulo_mazo" únicos
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

              // Calculamos cuántas tarjetas tiene este mazo exacto
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
// PANTALLA 2: MODO ESTUDIO (CARRUSEL ANIMADO)
// =========================================================================
// =========================================================================
// PANTALLA 2: MODO ESTUDIO (CARRUSEL ANIMADO)
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
  
  // 1. Creamos una variable para guardar la conexión a la base de datos
  late Stream<QuerySnapshot> _streamTarjetas;

  @override
  void initState() {
    super.initState();
    // 2. Inicializamos la conexión UNA SOLA VEZ al abrir la pantalla
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
        // 3. Usamos la variable guardada en lugar de llamar a Firebase de nuevo
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
              // Contador de tarjetas (Ej: 1 de 10)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Tarjeta $_tarjetaActual de ${flashcards.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ),

              // Carrusel deslizable
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _tarjetaActual = index + 1; // Actualizamos el número sin reiniciar Firebase
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
                        key: ValueKey(idTarjeta), // Esto evita que las tarjetas se mezclen al pasar rápido
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
// WIDGET 3: LA TARJETA QUE GIRA (ANIMACIÓN 3D FLIP PROFESIONAL)
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
  // Controlador de la animación
  late AnimationController _controller;
  // Animación que va de 0 a 1 (lo convertiremos a ángulo luego)
  late Animation<double> _animation;
  // Estado para saber qué lado mostrar (evita parpadeos de texto)
  bool _esFrente = true;

  @override
  void initState() {
    super.initState();
    // Configuramos el controlador (duración suave de 0.6 segundos)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Definimos la curva de la animación (EaseInOut para que empiece y acabe suave)
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Escuchamos la animación para cambiar el estado del texto justo en la mitad del giro (90º)
    _controller.addListener(() {
      setState(() {
        // Si la animación ha pasado de la mitad, mostramos el reverso
        _esFrente = _controller.value < 0.5;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpieza del controlador
    super.dispose();
  }

  void _voltearTarjeta() {
    if (_esFrente) {
      _controller.forward(); // Gira hacia adelante (muestra respuesta)
    } else {
      _controller.reverse(); // Gira hacia atrás (muestra pregunta)
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _voltearTarjeta,
      // AnimatedBuilder reconstruye solo el giro, optimizando rendimiento
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculamos el ángulo actual en radianes (Pi = 180 grados)
          final anguloRadianes = _animation.value * pi;
          
          return Transform(
            // 1. Matriz de identidad (la base)
            transform: Matrix4.identity()
              // 2. Perspectiva (¡ESTA ES LA MAGIA! Da sensación de profundidad 3D)
              // El valor 0.001 hace que lo que esté lejos se vea más pequeño.
              ..setEntry(3, 2, 0.001)
              // 3. Rotación sobre el eje Y (vertical)
              ..rotateY(anguloRadianes),
            // Alineamos la rotación en el centro de la tarjeta
            alignment: Alignment.center,
            
            child: _esFrente
                ? _construirLadoTarjeta(
                    texto: widget.pregunta,
                    colorFondo: Colors.white,
                    colorTexto: Colors.blue.shade900,
                    etiqueta: 'PREGUNTA',
                    icono: Icons.help_outline,
                  )
                // Usamos Transform.scale(-1, 1) en el reverso para que el texto NO salga al revés (efecto espejo)
                : Transform.scale(
                    scaleX: -1, // Volteamos el reverso horizontalmente
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

  // Diseño visual de la tarjeta (mejorado un poco también)
  Widget _construirLadoTarjeta({
    required String texto,
    required Color colorFondo,
    required Color colorTexto,
    required String etiqueta,
    required IconData icono,
  }) {
    return Card(
      color: colorFondo,
      elevation: 12, // Más sombra para dar efecto de "flotar" en el 3D
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28), // Bordes más redondeados
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // Cabecera elegante
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
                    letterSpacing: 2.0, // Espaciado entre letras profesional
                  ),
                ),
              ],
            ),
            const Spacer(), // Empuja el texto al centro
            // Texto principal (centrado y grande)
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26, // Texto un poco más grande
                fontWeight: FontWeight.w700,
                color: colorTexto,
                height: 1.2, // Espaciado entre líneas
              ),
            ),
            const Spacer(), // Empuja el texto al centro
            // Pie de tarjeta sutil
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