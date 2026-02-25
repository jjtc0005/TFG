import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum MetodoEntrada { texto, imagen, archivo }

class CreateFlashcardScreen extends StatefulWidget {
  const CreateFlashcardScreen({super.key});

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreen();
}

class _CreateFlashcardScreen extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _numTarjetasController = TextEditingController();

  MetodoEntrada _metodoSeleccionado = MetodoEntrada.archivo;

  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  /// Método que limpia la memoria o el estado cuando se cierra la ventana
  @override
  void dispose() {
    _tituloController.dispose();
    _almacenController.dispose();
    _numTarjetasController.dispose();
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? fotoTomada = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (fotoTomada != null) {
        setState(() {
          _imagenSeleccionada = File(fotoTomada.path);
        });
      }
    } catch (e) {
      print("Error al abrir la cámara: $e");
    }
  }

  void _borrarFoto() {
    setState(() {
      _imagenSeleccionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear flashcards'), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Datos principales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Titulo del Mazo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _almacenController,
              decoration: const InputDecoration(
                labelText: 'Almacén / Carpeta (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _numTarjetasController,
              keyboardType: TextInputType
                  .number, // Al definir número abre el teclado numérico
              decoration: const InputDecoration(
                labelText: 'Número de flashcards deseadas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Introduce un número";
                }
                if (int.tryParse(value) == null) {
                  return "Debe ser un número válido";
                }
                return null;
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            SegmentedButton<MetodoEntrada>(
              segments: const [
                ButtonSegment(
                  value: MetodoEntrada.texto,
                  label: Text('Texto'),
                  icon: Icon(Icons.text_snippet),
                ),

                ButtonSegment(
                  value: MetodoEntrada.imagen,
                  label: Text('Imagen'),
                  icon: Icon(Icons.image),
                ),
                ButtonSegment(
                  value: MetodoEntrada.archivo,
                  label: Text('Archivo'),
                  icon: Icon(Icons.upload_file),
                ),
              ],

              selected: {_metodoSeleccionado},
              onSelectionChanged: (Set<MetodoEntrada> nuevaSeleccion) {
                setState(() {
                  _metodoSeleccionado = nuevaSeleccion.first;
                });
              },
            ),

            const SizedBox(height: 24),
            // --- 3. ÁREA DINÁMICA (Cambia según lo elegido arriba) ---
            if (_metodoSeleccionado == MetodoEntrada.texto)
              TextFormField(
                maxLines: 6, // Caja grande para apuntes
                decoration: const InputDecoration(
                  labelText: 'Pega aquí tus apuntes...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              )
            else if (_metodoSeleccionado == MetodoEntrada.imagen)
              _imagenSeleccionada != null
                  ? _mostrarMiniaturaFoto()
                  : _crearBotonSubida(
                      Icons.camera_alt,
                      'Tomar Foto o Subir Imagen',
                      _tomarFoto,
                    )
            else if (_metodoSeleccionado == MetodoEntrada.archivo)
              _crearBotonSubida(
                Icons.picture_as_pdf,
                'Subir PDF o Documento',
                () {
                  print("");
                },
              ),

            const SizedBox(height: 40),

            // --- 4. BOTÓN FINAL ---
            FilledButton.icon(
              onPressed: () {
                // Si todos los campos obligatorios están rellenos...
                if (_formKey.currentState!.validate()) {
                  print("¡Todo listo para generar con IA!");
                  // Aquí llamaremos a Gemini en el futuro
                }
              },
              icon: const Icon(Icons.auto_awesome), // Icono de IA
              label: const Text(
                'Generar Flashcards',
                style: TextStyle(
                  fontSize: 16,
                  // padding: EdgeInsets.all(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearBotonSubida(IconData icono, String texto, VoidCallback accion) {
    return InkWell(
      onTap: accion,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 40, color: Colors.blueGrey),
              const SizedBox(height: 8),
              Text(texto, style: const TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mostrarMiniaturaFoto() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _imagenSeleccionada!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover, // Para que la foto rellene bien el cuadro
          ),
        ),
        // Botón rojo para eliminar la foto si nos ha salido movida
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
          onPressed: _borrarFoto,
        ),
      ],
    );
  }
}
