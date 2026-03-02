import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer';

enum MetodoEntrada { texto, imagen, archivo }

class CreateFlashcardScreen extends StatefulWidget {
  const CreateFlashcardScreen({super.key});

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreen();
}

class _CreateFlashcardScreen extends State<CreateFlashcardScreen> {
  // Llave maestra del formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _numTarjetasController = TextEditingController();
  final TextEditingController _apuntesController = TextEditingController(); // NUEVO: Para leer los apuntes

  // Estado del selector (por defecto en texto)
  MetodoEntrada _metodoSeleccionado = MetodoEntrada.texto;

  // Variables para la imagen
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  // Variables para el archivo
  File? _archivoSeleccionado;
  String? _nombreArchivo;

  /// Método que limpia la memoria o el estado cuando se cierra la ventana
  @override
  void dispose() {
    _tituloController.dispose();
    _almacenController.dispose();
    _numTarjetasController.dispose();
    _apuntesController.dispose(); // Limpiamos el nuevo controlador
    super.dispose();
  }

  // --- FUNCIONES DE CÁMARA ---
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

  // --- FUNCIONES DE ARCHIVO ---
  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (resultado != null) {
        setState(() {
          _archivoSeleccionado = File(resultado.files.single.path!);
          _nombreArchivo = resultado.files.single.name;
        });
      }
    } catch (e) {
      print("Error al seleccionar el archivo: $e");
    }
  }

  void _borrarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _nombreArchivo = null;
    });
  }

  // --- FUNCIÓN DE INTELIGENCIA ARTIFICIAL ACTUALIZADA ---
  Future<void> _generarConIA() async {
    const apiKey = 'AIzaSyBNyetBhigUkCuJyd93Q-lo3DYVyLNIXJg'; // Tu clave

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final cantidad = _numTarjetasController.text;
    final tema = _tituloController.text;
    String contexto = ""; // <--- AQUÍ GUARDAMOS EL TEXTO, FOTO O PDF

    // 1. Comprobamos qué método ha elegido el usuario
    if (_metodoSeleccionado == MetodoEntrada.texto) {
      if (_apuntesController.text.isEmpty) {
        print("Error: No has escrito nada en los apuntes.");
        return; // Cortamos la ejecución si está vacío
      }
      contexto = _apuntesController.text;
    } else if (_metodoSeleccionado == MetodoEntrada.imagen) {
      // TODO: Próximo paso
      print("Aún tenemos que programar cómo enviarle la foto a Gemini.");
      return;
    } else if (_metodoSeleccionado == MetodoEntrada.archivo) {
      // TODO: Próximo paso
      print("Aún tenemos que programar cómo enviarle el PDF a Gemini.");
      return;
    }

    // 2. ¡El Súper Prompt! Ahora incluye el contexto del usuario
    final prompt =
        '''
      Eres un experto en crear material de estudio efectivo. Tu tarea obligatoria es generar EXACTAMENTE $cantidad flashcards (tarjetas de pregunta y respuesta) basándote ÚNICAMENTE en el texto proporcionado.
      
      Reglas estrictas y obligatorias:
      1. CANTIDAD EXACTA: Debes devolver exactamente $cantidad tarjetas. Ni una más, ni una menos. Es tu prioridad máxima.
      2. CÓMO LLEGAR AL NÚMERO: Si el texto parece corto, divide los conceptos grandes en preguntas más pequeñas y específicas. Pregunta por fechas exactas, nombres, definiciones individuales, causas por separado y consecuencias por separado. Exprime cada detalle del texto para alcanzar las $cantidad tarjetas.
      3. VERACIDAD: Todo debe salir del texto de origen. No inventes datos externos.
      
      Texto de origen:
      """
      $contexto
      """
      
      IMPORTANTE: Devuelve tu respuesta ÚNICAMENTE en el siguiente formato JSON exacto, sin comillas invertidas de markdown (```json), ni texto antes o después. Solo el array JSON puro:
      [
        {"pregunta": "Pregunta 1", "respuesta": "Respuesta 1"},
        {"pregunta": "Pregunta 2", "respuesta": "Respuesta 2"}
      ]
    ''';

    try {
      print("⏳ Leyendo tus apuntes y enviando a Gemini...");
      print("Se han pedido $cantidad de flashcards ");

      // Enviamos el súper prompt
      final response = await model.generateContent([Content.text(prompt)]);

      print("Gemini ha respondido!");

      log(response.text ?? "No hay texto ");

    } catch (e) {
      print("Error al hablar con Gemini: $e");
    }
  }

  // --- INTERFAZ VISUAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear flashcards'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
                  labelText: 'Título del Mazo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _almacenController,
                decoration: const InputDecoration(
                  labelText: 'Almacén / Carpeta (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _numTarjetasController,
                keyboardType: TextInputType.number,
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

              // --- ÁREA DINÁMICA ---
              if (_metodoSeleccionado == MetodoEntrada.texto)
                TextFormField(
                  controller:
                      _apuntesController, // <-- AÑADIDO: Ahora guardará lo que escribas
                  maxLines: 6,
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
                _archivoSeleccionado != null
                    ? _mostrarArchivoSeleccionado()
                    : _crearBotonSubida(
                        Icons.picture_as_pdf,
                        'Subir PDF o Documento',
                        _seleccionarArchivo,
                      ),

              const SizedBox(height: 40),

              // --- BOTÓN FINAL ---
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _generarConIA();
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Generar Flashcards',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO VISUAL ---
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
            fit: BoxFit.cover,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
          onPressed: _borrarFoto,
        ),
      ],
    );
  }

  Widget _mostrarArchivoSeleccionado() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.blueAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _nombreArchivo ?? 'Archivo seleccionado',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _borrarArchivo,
          ),
        ],
      ),
    );
  }
}
