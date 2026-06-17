import 'package:flashcardstfg/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectorCarpeta extends StatelessWidget {
  final String? carpetaSeleccionada;
  final bool creandoNuevaCarpeta;
  final TextEditingController almacenController;
  final Function(String?, bool) onChanged;

  const SelectorCarpeta({
    super.key,
    required this.carpetaSeleccionada,
    required this.creandoNuevaCarpeta,
    required this.almacenController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Carpetas')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DropdownMenuItem<String>> opciones = [];

        for (var doc in snapshot.data!.docs) {
          String nombre = doc['Nombre'] ?? 'Sin nombre';
          opciones.add(
            DropdownMenuItem(value: nombre, child: Text(nombre)),
          );
        }

        opciones.add(
          DropdownMenuItem(
            value: 'NUEVA',
            child: Text(
              '➕ ${AppLocalizations.of(context)!.nuevaCarpeta}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );

        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.seleccionCarpeta,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              items: opciones,
              value: opciones.any((item) => item.value == carpetaSeleccionada)
                  ? carpetaSeleccionada
                  : null,
              onChanged: (String? nuevoValor) {
                
                onChanged(nuevoValor, nuevoValor == 'NUEVA');
              },
              validator: (value) => value == null ? 'Selecciona una carpeta' : null,
            ),
            if (creandoNuevaCarpeta) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: almacenController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.nombreCarpeta,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.create_new_folder),
                ),
                validator: (value) {
                  if (creandoNuevaCarpeta && (value == null || value.isEmpty)) {
                    return '${AppLocalizations.of(context)?.escribirnombre}';
                  }
                  return null;
                },
              ),
            ],
          ],
        );
      },
    );
  }
}