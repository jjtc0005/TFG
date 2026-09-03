import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcardstfg/l10n/app_localizations.dart';
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
  // --- AÑADIDO: Parámetros opcionales para saber si venimos desde dentro de una carpeta ---
  final String? carpetaIdPredefinida;
  final String? nombreCarpetaPredefinida;

  const CreateFlashcardScreen({
    super.key, 
    this.carpetaIdPredefinida, 
    this.nombreCarpetaPredefinida
  });
  // --- FIN DEL AÑADIDO ---

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreen();
}

class _CreateFlashcardScreen extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _mensajeCarga;
  String? _errorContenido;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _numTarjetasController = TextEditingController();
  final TextEditingController _apuntesController = TextEditingController();

  String? _carpetaSeleccionada;
  bool _creandoNuevaCarpeta = false;

  MetodoEntrada _metodoSeleccionado = MetodoEntrada.texto;

  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  final int limiteMaximoTarjetas = 30;

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

  Future<void> _tomarFoto() async {
    try {
      final XFile? fotoTomada = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (fotoTomada != null) {
        setState(() {
          _imagenSeleccionada = File(fotoTomada.path);
          _errorContenido = null;
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
          _errorContenido = null; 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.crearFlashcard),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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
              Text(
                AppLocalizations.of(context)!.datosprincipales,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.tituloMazo),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${AppLocalizations.of(context)!.errorTitulo} ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- MODIFICADO: Condicional para mostrar selector o texto fijo ---
              if (widget.nombreCarpetaPredefinida != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Guardando en: ${widget.nombreCarpetaPredefinida}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
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
              // --- FIN DE LO MODIFICADO ---
              
              const SizedBox(height: 16),

              TextFormField(
                controller: _numTarjetasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.numFlashcards,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.blueAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.rendimiento, style: const TextStyle(fontSize: 18)),                            ],
                          ),
                          content: Text(AppLocalizations.of(context)!.mensajeRendimiento),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.entendido),                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "${AppLocalizations.of(context)!.numero} ";
                  }
                  
                  final int? cantidadParseada = int.tryParse(value);
                  
                  if (cantidadParseada == null) {
                    return "${AppLocalizations.of(context)!.errorNum} ";
                  }
                  if (cantidadParseada <= 0) {
                    return "Debe generar al menos 1 tarjeta"; 
                  }
                  if (cantidadParseada > limiteMaximoTarjetas) {
                    return "El límite es de $limiteMaximoTarjetas tarjetas por petición"; 
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              SegmentedButton<MetodoEntrada>(
                segments: [
                  ButtonSegment(
                    value: MetodoEntrada.texto,
                    label: Text(AppLocalizations.of(context)!.texto),
                    icon: Icon(Icons.text_snippet),
                  ),
                  ButtonSegment(
                    value: MetodoEntrada.imagen,
                    label: Text(AppLocalizations.of(context)!.imagen),
                    icon: Icon(Icons.image),
                  ),
                  ButtonSegment(
                    value: MetodoEntrada.archivo,
                    label: Text(AppLocalizations.of(context)!.archivo),
                    icon: Icon(Icons.upload_file),
                  ),
                ],
                selected: {_metodoSeleccionado},
                onSelectionChanged: (Set<MetodoEntrada> nuevaSeleccion) {
                  setState(() {
                    _metodoSeleccionado = nuevaSeleccion.first;
                    _errorContenido = null; 
                  });
                },
              ),

              const SizedBox(height: 24),

              if (_metodoSeleccionado == MetodoEntrada.texto)
                TextFormField(
                  controller: _apuntesController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.pegarApuntes} ',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                )
              else if (_metodoSeleccionado == MetodoEntrada.imagen)
                _imagenSeleccionada != null
                    ? _mostrarMiniaturaFoto()
                    : _crearBotonSubida(
                        Icons.camera_alt,
                        AppLocalizations.of(context)!.tomarFoto,
                        _tomarFoto,
                      )
              else if (_metodoSeleccionado == MetodoEntrada.archivo)
                _archivoSeleccionado != null
                    ? _mostrarArchivoSeleccionado()
                    : _crearBotonSubida(
                        Icons.picture_as_pdf,
                        AppLocalizations.of(context)!.subirArchivo,
                        _seleccionarArchivo,
                      ),
              
              if (_errorContenido != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorContenido!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              _mensajeCarga != null
                  ? Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _mensajeCarga!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FilledButton.icon(
                    onPressed: () {
                      bool formularioValido = _formKey.currentState!.validate();
                      bool contenidoValido = true;
                      if (_metodoSeleccionado == MetodoEntrada.texto &&
                          _apuntesController.text.trim().isEmpty) {
                        setState(() {
                          _errorContenido = AppLocalizations.of(context)!.errorContenidoTexto;
                        });
                        contenidoValido = false;
                      } else if (_metodoSeleccionado == MetodoEntrada.imagen &&
                          _imagenSeleccionada == null) {
                        setState(() {
                          _errorContenido = AppLocalizations.of(context)!.errorContenidoImagen;
                        });
                        contenidoValido = false;
                      } else if (_metodoSeleccionado == MetodoEntrada.archivo &&
                          _archivoSeleccionado == null) {
                        setState(() {
                          _errorContenido = AppLocalizations.of(context)!.errorContenidoArchivo;
                        });
                        contenidoValido = false;
                      } else {
                        setState(() => _errorContenido = null);
                      }
                      if (formularioValido && contenidoValido) {
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
                      label: Text(
                        AppLocalizations.of(context)!.generarFlashcards,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generarConIA() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      print(AppLocalizations.of(context)!.errorAPI);
      return;
    }

    final model = GenerativeModel(model: 'gemini-3.1-flash-lite', apiKey: apiKey);
    final cantidad = _numTarjetasController.text;

    final reglaIdioma = AppLocalizations.of(context)!.reglaIdioma;

    List<Part> partesPrompt = [];

    final promptInstrucciones =
        '''
      Eres un experto en crear material de estudio efectivo. 
      Tu tarea obligatoria es generar EXACTAMENTE $cantidad flashcards 
      (tarjetas de pregunta y respuesta) basándote ÚNICAMENTE en el contenido que te proporciono.
      
      REGLA DE IDIOMA ESTRICTA: $reglaIdioma

      Reglas estrictas y obligatorias:
      1. CANTIDAD EXACTA: Debes devolver exactamente $cantidad tarjetas.
      2. CÓMO LLEGAR AL NÚMERO: Divide los conceptos grandes en preguntas más pequeñas.
      3. VERACIDAD: Todo debe salir del contenido proporcionado.
      4. EXCEPCIÓN DE CONTENIDO: Si la imagen, documento o texto proporcionado NO contiene información útil, es ilegible, o no hay texto real, debes devolver EXACTAMENTE un arreglo JSON vacío: []
      
      IMPORTANTE: Devuelve tu respuesta ÚNICAMENTE en JSON:
      [
        {"pregunta": "P1", "respuesta": "R1"}
      ]
    ''';

    if (_metodoSeleccionado == MetodoEntrada.texto) {
      if (_apuntesController.text.isEmpty) return;

      partesPrompt.add(
        TextPart("$promptInstrucciones\n\nTexto:\n${_apuntesController.text}"),
      );
    } else if (_metodoSeleccionado == MetodoEntrada.archivo) {
      if (_archivoSeleccionado == null) return;

      setState(
        () => _mensajeCarga = AppLocalizations.of(context)!.prepararArchivo,
      );

      partesPrompt.add(TextPart(promptInstrucciones));

      final bytesDelArchivo = await _archivoSeleccionado!.readAsBytes();

      if (bytesDelArchivo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El archivo está vacío. Sube uno con contenido.')),
        );
        return;
      }

      final nombreEnMinusculas = _nombreArchivo!.toLowerCase();

      if (nombreEnMinusculas.endsWith('.pdf')) {
        partesPrompt.add(DataPart('application/pdf', bytesDelArchivo));
      } else if (nombreEnMinusculas.endsWith('.txt')) {
        partesPrompt.add(DataPart('text/plain', bytesDelArchivo));
      }
    } else if (_metodoSeleccionado == MetodoEntrada.imagen) {
      if (_imagenSeleccionada == null) return;

      setState(
        () => _mensajeCarga = AppLocalizations.of(context)!.procesarImagen,
      );
      partesPrompt.add(TextPart(promptInstrucciones));

      final bytesDeImagen = await _imagenSeleccionada!.readAsBytes();
      final ruta = _imagenSeleccionada!.path.toLowerCase();
      String tipoMime = 'image/jpeg';

      if (ruta.endsWith('.png'))
        tipoMime = 'image/png';
      else if (ruta.endsWith('.webp'))
        tipoMime = 'image/webp';

      partesPrompt.add(DataPart(tipoMime, bytesDeImagen));
    }

    try {
      final resultado = await InternetAddress.lookup('google.com');
      if (resultado.isEmpty) {
        throw SocketException(AppLocalizations.of(context)!.noInternet);
      }
    } catch (_) {
      setState(() => _mensajeCarga = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noInternet)),
        );
      }
      return;
    }

    try {
      setState(
        () => _mensajeCarga = AppLocalizations.of(context)!.analizandoIA,
      );

      // --- BENCHMARK: Cronómetro para medir rendimiento ---
      final cronometro = Stopwatch()..start();

      final response = await model.generateContent([
        Content.multi(partesPrompt),
      ]);

      final tiempoIA = cronometro.elapsedMilliseconds;
      print('[BENCHMARK] Tiempo IA: ${tiempoIA}ms (${(tiempoIA / 1000).toStringAsFixed(1)}s) — Tarjetas pedidas: $cantidad');

      setState(() => _mensajeCarga = AppLocalizations.of(context)!.saveFl);
      if (mounted) {
        await _guardarRepuestaBbdd(response.text ?? '');
      }

      final tiempoTotal = cronometro.elapsedMilliseconds;
      cronometro.stop();
      print('[BENCHMARK] Tiempo TOTAL (IA + BBDD): ${tiempoTotal}ms (${(tiempoTotal / 1000).toStringAsFixed(1)}s) — Tarjetas pedidas: $cantidad');
      
      // --- FIN BENCHMARK ---
    } catch (e) {


      setState(() => _mensajeCarga = null);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.errorIA} $e')));
      }
    }
  }

  Future<void> _guardarRepuestaBbdd(String respuestaGemini) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return;

      String jsonLimpio = respuestaGemini
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      List<dynamic> tarjetasGeneradas;

      try{
        tarjetasGeneradas = jsonDecode(jsonLimpio);

      }catch(e){

        if (mounted) {
          setState(() => _mensajeCarga = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se detectó información útil en la imagen o documento. Inténtalo de nuevo.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      String nombreCarpeta = "General";

      if (_creandoNuevaCarpeta && _almacenController.text.isNotEmpty) {
        nombreCarpeta = _almacenController.text;
      } else if (_carpetaSeleccionada != null && _carpetaSeleccionada != 'NUEVA') {
        nombreCarpeta = _carpetaSeleccionada!;
      }

      final carpetaPath = FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('Carpetas');
          
      String carpetaDestino;

      // --- MODIFICADO: Condicional para no buscar la carpeta si ya sabemos su ID ---
      if (widget.carpetaIdPredefinida != null) {
        carpetaDestino = widget.carpetaIdPredefinida!;
      } else {
        final busqueda = await carpetaPath
            .where("Nombre", isEqualTo: nombreCarpeta)
            .get();

        if (busqueda.docs.isNotEmpty) {
          carpetaDestino = busqueda.docs.first.id;
        } else {
          final nuevaCarpeta = await carpetaPath.add({
            "Nombre": nombreCarpeta,
            "fechaCreacion": FieldValue.serverTimestamp(),
          });
          carpetaDestino = nuevaCarpeta.id;
        }
      }
      // --- FIN DE LO MODIFICADO ---

      final mazoRef = carpetaPath.doc(carpetaDestino).collection('Mazos').doc();

      final batch = FirebaseFirestore.instance.batch();

      batch.set(mazoRef, {
        'titulo': _tituloController.text,
        'cantidad_tarjetas': tarjetasGeneradas.length,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

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

      await batch.commit();

      if (mounted) {
        setState(() => _mensajeCarga = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mazogenerado),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      setState(() => _mensajeCarga = null);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorBaseDatos)));
      }
    }
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
              _nombreArchivo ?? AppLocalizations.of(context)!.archivoSeleccionado,
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