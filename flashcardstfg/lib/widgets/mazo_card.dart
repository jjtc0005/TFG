import 'package:flutter/material.dart';
import 'package:flashcardstfg/screens/Flashcardslistscreen.dart';

class MazoCard extends StatelessWidget {
  final String tituloMazo;
  final int cantidadTarjetas;
  final String carpetaId;

  const MazoCard({
    super.key,
    required this.tituloMazo,
    required this.cantidadTarjetas,
    required this.carpetaId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2, // Un toque extra de sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.style, color: Colors.blue),
        ),
        title: Text(
          tituloMazo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '$cantidadTarjetas tarjetas',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navegación encapsulada dentro de la propia tarjeta
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardsListScreen(
                carpetaId: carpetaId,
                tituloMazo: tituloMazo,
              ),
            ),
          );
        },
      ),
    );
  }
}