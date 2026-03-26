import 'package:flutter/material.dart';
import 'dart:math';

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