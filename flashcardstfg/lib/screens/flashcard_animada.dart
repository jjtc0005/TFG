import 'package:flashcardstfg/l10n/app_localizations.dart';
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

class _FlashcardAnimadaState extends State<FlashcardAnimada>
    with SingleTickerProviderStateMixin {
  // Controlador de la animación
  late AnimationController _controller;

  // Animación que va de 0 a 1, sirve para el ángulo
  late Animation<double> _animation;

  // Estado para saber qué lado mostrar
  bool _esFrente = true;

  @override
  void initState() {
    super.initState();

    // Configuramos el controlador, duración suave de 0.6 segundos
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Definimos la curva de la animación (EaseInOut para que empiece y acabe suave)
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    // ANVERSO: Negro en modo oscuro, Blanco en claro
                    colorFondo: isDarkMode
                        ? const Color(0xFF121212)
                        : Colors.white,
                    colorTexto: isDarkMode
                        ? Colors.white
                        : Colors.blue.shade900,
                    etiqueta: AppLocalizations.of(context)!.pregunta,
                    icono: Icons.help_outline,
                    isDarkMode: isDarkMode,
                  )
                : Transform.scale(
                    scaleX: -1,
                      child: _construirLadoTarjeta(
                        texto: widget.respuesta,
                        colorFondo: isDarkMode
                            ? const Color(0xFF0D2B16)
                            : Colors.green.shade50,
                        // ARREGLADO: Blanco en modo oscuro, y un verde muy oscuro/negro en modo claro
                        colorTexto: isDarkMode
                            ? Colors.white
                            : Colors.green.shade900, // <--- Este es oscuro y elegante
                        etiqueta: AppLocalizations.of(context)!.respuesta,
                        icono: Icons.check_circle_outline,
                        isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    return Card(
      color: colorFondo,
      elevation: isDarkMode ? 2 : 12,
      shadowColor: isDarkMode ? Colors.black : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        // BORDE: Blanco en modo oscuro como pediste, azul en claro
        side: BorderSide(
          color: isDarkMode ? Colors.white : Colors.blue.shade100,
          width: 2.0, // Un poco más grueso para que resalte el borde blanco
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de cabecera más visible
                Icon(
                  icono,
                  size: 20,
                  color: isDarkMode ? Colors.white70 : Colors.blueGrey.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  etiqueta,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : Colors.blueGrey.shade400,
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
            // TEXTO DE ABAJO: Ahora pasa a blanco en modo oscuro
            Text(
              AppLocalizations.of(context)!.voltear,
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
