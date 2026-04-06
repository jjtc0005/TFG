import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcardstfg/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flashcardstfg/widgets/selector_carpeta.dart';

enum MetodoEntrada { texto, imagen, archivo }

class CreateFlashcardScreen extends StatefulWidget {
  const CreateFlashcardScreen({super.key});

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreen();
}

class _CreateFlashcardScreen extends State<CreateFlashcardScreen> {
  // Llave maestra del formulario
  final _formKey = GlobalKey<FormState>();
  String? _mensajeCarga;

  // Controladores de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _numTarjetasController = TextEditingController();
  final TextEditingController _apuntesController = TextEditingController();

  // --- NUEVAS VARIABLES PARA EL DESPLEGABLE DE CARPETAS ---
  String? _carpetaSeleccionada;
  bool _creandoNuevaCarpeta = false;

  // Estado del selector (por defecto en texto)
  MetodoEntrada _metodoSeleccionado = MetodoEntrada.texto;

  // Variables para la imagen
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  // Variables para el archivo
  File? _archivoSeleccionado;
  String? _nombreArchivo;

  @override
  void dispose() {
    _tituloController.dispose();
    _almacenController.dispose();
    _numTarjetasController.dispose();
    _apuntesController.dispose();
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

  /// Función que envía el prompt a la IA de Google Gemini
  // --- INTERFAZ VISUAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear flashcards'),
        centerTitle: true,
        // --- BOTÓN DE VOLVER ATRÁS MEJORADO ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            // 1. Intentamos volver de forma natural
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // 2. Si no hay historial, forzamos la navegación al Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            }
          },
        ),
      ),
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

              // Selector de la carpeta extraido a widget
              SelectorCarpeta(
                carpetaSeleccionada: _carpetaSeleccionada,
                creandoNuevaCarpeta: _creandoNuevaCarpeta,
                almacenController: _almacenController,
                onChanged: (nuevoValor, esNueva) {
                  setState(() {
                    _carpetaSeleccionada = nuevoValor;
                    _creandoNuevaCarpeta = esNueva;
                  });
                },
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
                  controller: _apuntesController,
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

            // Botón final
              _mensajeCarga != null
                  ? Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _mensajeCarga!, 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _generarConIA(); 
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generar Flashcards', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

/// Función optimizada que envía el prompt a Gemini
  Future<void> _generarConIA() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      print("Error en la lectura de la api");
      return;
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    final cantidad = _numTarjetasController.text;

    List<Part> partesPrompt = [];

    // ... (Tu prompt se queda igual) ...
    final promptInstrucciones =
        '''
      Eres un experto en crear material de estudio efectivo. Tu tarea obligatoria es generar EXACTAMENTE $cantidad flashcards (tarjetas de pregunta y respuesta) basándote ÚNICAMENTE en el contenido que te proporciono.
      
      Reglas estrictas y obligatorias:
      1. CANTIDAD EXACTA: Debes devolver exactamente $cantidad tarjetas.
      2. CÓMO LLEGAR AL NÚMERO: Divide los conceptos grandes en preguntas más pequeñas.
      3. VERACIDAD: Todo debe salir del contenido proporcionado.
      
      IMPORTANTE: Devuelve tu respuesta ÚNICAMENTE en JSON:
      [
        {"pregunta": "P1", "respuesta": "R1"}
      ]
    ''';

    if (_metodoSeleccionado == MetodoEntrada.texto) {

      if (_apuntesController.text.isEmpty) return;

      partesPrompt.add(TextPart("$promptInstrucciones\n\nTexto:\n${_apuntesController.text}"));
    } 
    else if (_metodoSeleccionado == MetodoEntrada.archivo) {

      if (_archivoSeleccionado == null) return;
      
      setState(() => _mensajeCarga = "Preparando archivo...");
      
      partesPrompt.add(TextPart(promptInstrucciones));
      
      final bytesDelArchivo = await _archivoSeleccionado!.readAsBytes();
      final nombreEnMinusculas = _nombreArchivo!.toLowerCase();

      if (nombreEnMinusculas.endsWith('.pdf')) {
        partesPrompt.add(DataPart('application/pdf', bytesDelArchivo));
      } else if (nombreEnMinusculas.endsWith('.txt')) {
        partesPrompt.add(DataPart('text/plain', bytesDelArchivo));
      }
    } else if (_metodoSeleccionado == MetodoEntrada.imagen) {

      if (_imagenSeleccionada == null) return;
      
      setState(() => _mensajeCarga = "Procesando imagen...");
      partesPrompt.add(TextPart(promptInstrucciones));

      final bytesDeImagen = await _imagenSeleccionada!.readAsBytes();
      final ruta = _imagenSeleccionada!.path.toLowerCase();
      String tipoMime = 'image/jpeg';

      if (ruta.endsWith('.png')) tipoMime = 'image/png';
      else if (ruta.endsWith('.webp')) tipoMime = 'image/webp';
      
      partesPrompt.add(DataPart(tipoMime, bytesDeImagen));

    }

    // Comprobamos Internet
    try {
      final resultado = await InternetAddress.lookup('google.com');
      if (resultado.isEmpty) throw const SocketException('Sin internet');
    } catch (_) {
      setState(() => _mensajeCarga = null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin internet.')));
      return;
    }

    try {
      // Damos feedback de que estamos subiendo los datos (la fase más lenta)
      setState(() => _mensajeCarga = "Analizando con Inteligencia Artificial...");
      
      final response = await model.generateContent([Content.multi(partesPrompt)]);
      
      // Pasamos a la fase de guardado
      setState(() => _mensajeCarga = "Guardando flashcards...");
      if (mounted) {
        await _guardarRepuestaBbdd(response.text ?? '');
      }
    } catch (e) {
      setState(() => _mensajeCarga = null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error IA: $e')));
    }
  }

  /// Permite guardar en la base de datos la respuesta de la IA con las 
  /// flashcards en batch creando una instancia vacía que podemos rellenar y volver
  /// a actualizar, esto optimiza la versión anterior que creaba en memoria una
  /// tarjeta y la rellenaba de una en una
  Future<void> _guardarRepuestaBbdd(String respuestaGemini) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return;

      String jsonLimpio = respuestaGemini.replaceAll('```json', '').replaceAll('```', '').trim();
      List<dynamic> tarjetasGeneradas = jsonDecode(jsonLimpio);

      String nombreCarpeta = "General";

      if (_creandoNuevaCarpeta && _almacenController.text.isNotEmpty) {
        nombreCarpeta = _almacenController.text;
      } else if (_carpetaSeleccionada != null && _carpetaSeleccionada != 'NUEVA') {
        nombreCarpeta = _carpetaSeleccionada!;
      }

      final carpetaPath = FirebaseFirestore.instance.collection('users').doc(usuario.uid).collection('Carpetas');
      String carpetaDestino;

      final busqueda = await carpetaPath.where("Nombre", isEqualTo: nombreCarpeta).get();

      if (busqueda.docs.isNotEmpty) {
        carpetaDestino = busqueda.docs.first.id;
      } else {
        final nuevaCarpeta = await carpetaPath.add({
          "Nombre": nombreCarpeta,
          "fechaCreacion": FieldValue.serverTimestamp(),
        });
        carpetaDestino = nuevaCarpeta.id;
      }

      // --- NUEVA ESTRUCTURA DE BASE DE DATOS OPTIMIZADA ---
      
      // 1. Creamos la referencia al nuevo Mazo (Catálogo)
      final mazoRef = carpetaPath.doc(carpetaDestino).collection('Mazos').doc();
      
      final batch = FirebaseFirestore.instance.batch();

      // 2. Guardamos los datos principales del Mazo
      batch.set(mazoRef, {
        'titulo': _tituloController.text,
        'cantidad_tarjetas': tarjetasGeneradas.length,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      // 3. La subcolección de flashcards ahora va DENTRO de ese mazo
      final flashcardsRef = mazoRef.collection('Flashcards');

      for (var tarjeta in tarjetasGeneradas) {
        final nuevaTarjetaRef = flashcardsRef.doc(); 
        batch.set(nuevaTarjetaRef, {
          'pregunta': tarjeta['pregunta'],
          'respuesta': tarjeta['respuesta'],
          'fechaCreacion': FieldValue.serverTimestamp(),
          'nivel': 0,
        });
      }

      await batch.commit(); // Subimos el Mazo y todas sus tarjetas de golpe

      if (mounted) {
        setState(() => _mensajeCarga = null); // Ocultamos la carga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Mazo generado al instante!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volvems al menú
      }
    } catch (e) {
      setState(() => _mensajeCarga = null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
    }
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
