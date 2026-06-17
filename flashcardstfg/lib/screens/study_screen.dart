import 'package:flashcardstfg/l10n/app_localizations.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            return Center(
              child: Text(
                AppLocalizations.of(context)!.carpetaVacia,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                  fontSize: 16,
                ),
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

              final tituloMazo =
                  data['titulo'] ?? AppLocalizations.of(context)!.sintitulo;
              final cantidadTarjetas = data['cantidad_tarjetas'] ?? 0;
              final mazoId = docMazo.id;

              return Card(
                elevation: isDarkMode
                    ? 1
                    : 3, // Sombras más sutiles en modo oscuro
                color: isDarkMode
                    ? Colors.grey[850]
                    : Colors.white, // Fondo de la lista
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDarkMode ? Colors.white12 : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isDarkMode
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.blue.shade100,
                    child: Icon(
                      Icons.style,
                      color: isDarkMode ? Colors.blue.shade200 : Colors.blue,
                    ),
                  ),
                  title: Text(
                    tituloMazo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '$cantidadTarjetas ${AppLocalizations.of(context)!.tarjetas}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
                    ),
                  ),
                  trailing: Icon(
                    Icons.play_circle_fill,
                    size: 30,
                    color: isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blueAccent,
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
    // 1. Detectamos el modo oscuro aquí
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. ARREGLADO: Si es de noche, usa el fondo por defecto (oscuro), si es de día, tu gris clarito
      backgroundColor: isDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.tituloMazo),
        centerTitle:
            true, // Opcional, pero suele quedar mejor centrado en esta vista
        // 1. Le forzamos el MISMO color exacto que tiene tu Scaffold
        backgroundColor: isDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.grey.shade100,
        // 2. Le quitamos cualquier sombra base
        elevation: 0,
        // 3. Apagamos el efecto de sombreado automático al hacer scroll (el que viste en el Home)
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _streamTarjetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorTarjetas),
            );
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
                      ' ${AppLocalizations.of(context)!.tarjeta} $valorActual ${AppLocalizations.of(context)!.de} ${flashcards.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // 3. ARREGLADO: Blanco en oscuro, AzulGrisáceo en claro
                        color: isDarkMode ? Colors.white70 : Colors.blueGrey,
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

              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Text(
                  '👈 ${AppLocalizations.of(context)!.mensajeDeslizarTocar} 👆',
                  // 4. ARREGLADO: Gris claro en oscuro, gris normal en claro
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
