import 'package:flutter/material.dart';
import 'package:flashcardstfg/screens/study_screen.dart'; // Importante para la navegación

class CarpetaCard extends StatelessWidget {
  final String idCarpeta;
  final String nombreCarpeta;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CarpetaCard({
    super.key,
    required this.idCarpeta,
    required this.nombreCarpeta,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack( // Usamos Stack para poner el botón encima de todo
        children: [
          // 1. ÁREA CLICABLE PRINCIPAL (Para ir a estudiar)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyScreen(
                    carpetaId: idCarpeta,
                    nombreCarpeta: nombreCarpeta,
                  ),
                ),
              );
            },
            child: Container(
              // Usamos un padding superior para dejar hueco al botón
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), 
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_special, size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  // Nombre de la carpeta
                  Expanded( // Para que el texto no empuje el icono
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        nombreCarpeta,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 2. EL BOTÓN DE OPCIONES (En la esquina superior derecha)
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.blueGrey.shade300, size: 20),
              // Al elegir una opción...
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();   // Llamamos a editar
                } else if (value == 'delete') {
                  onDelete(); // Llamamos a borrar
                }
              },
              // Las opciones del menú
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                // Opción: Editar
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20, color: Colors.blueAccent),
                    title: Text('Editar nombre'),
                  ),
                ),
                // Opción: Borrar
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('Eliminar mazo'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}