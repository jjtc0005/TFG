import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectorCarpeta extends StatelessWidget {
  final String? carpetaSeleccionada;
  final bool creandoNuevaCarpeta;
  final TextEditingController almacenController;
  final Function(String?, bool) onChanged; // Avisa al padre de los cambios

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
          const DropdownMenuItem(
            value: 'NUEVA',
            child: Text(
              '➕ Crear nueva carpeta...',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );

        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Selecciona una Carpeta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              items: opciones,
              value: opciones.any((item) => item.value == carpetaSeleccionada)
                  ? carpetaSeleccionada
                  : null,
              onChanged: (String? nuevoValor) {
                // Ejecutamos la función que nos pasó el padre
                onChanged(nuevoValor, nuevoValor == 'NUEVA');
              },
              validator: (value) => value == null ? 'Selecciona una carpeta' : null,
            ),
            if (creandoNuevaCarpeta) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: almacenController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la nueva carpeta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.create_new_folder),
                ),
                validator: (value) {
                  if (creandoNuevaCarpeta && (value == null || value.isEmpty)) {
                    return 'Escribe el nombre de la carpeta';
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