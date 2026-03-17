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
  bool _isLoading = false;

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
  /// Función que envía el prompt a la IA de Google Gemini
  Future<void> _generarConIA() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      print("Error en la lectura de la api");
      return;
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    final cantidad = _numTarjetasController.text;

    List<Part> partesPrompt = [];

    // 1. ¡El Súper Prompt!
    final promptInstrucciones =
        '''
      Eres un experto en crear material de estudio efectivo. Tu tarea obligatoria es generar EXACTAMENTE $cantidad flashcards (tarjetas de pregunta y respuesta) basándote ÚNICAMENTE en el contenido que te proporciono.
      
      Reglas estrictas y obligatorias:
      1. CANTIDAD EXACTA: Debes devolver exactamente $cantidad tarjetas. Ni una más, ni una menos. Es tu prioridad máxima.
      2. CÓMO LLEGAR AL NÚMERO: Si el texto o documento parece corto, divide los conceptos grandes en preguntas más pequeñas y específicas. Exprime cada detalle para alcanzar las $cantidad tarjetas.
      3. VERACIDAD: Todo debe salir del contenido proporcionado. No inventes datos externos.
      
      IMPORTANTE: Devuelve tu respuesta ÚNICAMENTE en el siguiente formato JSON exacto, sin comillas invertidas de markdown (```json), ni texto antes o después. Solo el array JSON puro:
      [
        {"pregunta": "Pregunta 1", "respuesta": "Respuesta 1"},
        {"pregunta": "Pregunta 2", "respuesta": "Respuesta 2"}
      ]
    ''';

    // 2. Preparamos el contenido según lo que haya elegido el usuario
    if (_metodoSeleccionado == MetodoEntrada.texto) {
      if (_apuntesController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Escribe unos apuntes primero"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      partesPrompt.add(
        TextPart(
          "$promptInstrucciones\n\nTexto de origen:\n${_apuntesController.text}",
        ),
      );
    } else if (_metodoSeleccionado == MetodoEntrada.archivo) {
      if (_archivoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Selecciona un archivo con formato PDF o TXT primero.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      partesPrompt.add(TextPart(promptInstrucciones));

      final bytesDelArchivo = await _archivoSeleccionado!.readAsBytes();
      final nombreEnMinusculas = _nombreArchivo!.toLowerCase();

      // Clasificamos el archivo para que Gemini sepa cómo leerlo
      if (nombreEnMinusculas.endsWith('.pdf')) {
        partesPrompt.add(DataPart('application/pdf', bytesDelArchivo));
      } else if (nombreEnMinusculas.endsWith('.txt')) {
        partesPrompt.add(DataPart('text/plain', bytesDelArchivo));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por ahora, la IA solo admite archivos PDF o TXT.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else if (_metodoSeleccionado == MetodoEntrada.imagen) {
      if (_imagenSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Toma una foto de tus apuntes primero."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Añadimos las instrucciones al paquete
      partesPrompt.add(TextPart(promptInstrucciones));

      // ¡LA MAGIA DE LA VISIÓN! Convertimos la foto a formato binario
      final bytesDeImagen = await _imagenSeleccionada!.readAsBytes();

      // Averiguamos el formato de la imagen (jpeg, png...)
      final ruta = _imagenSeleccionada!.path.toLowerCase();
      String tipoMime =
          'image/jpeg'; // Por defecto casi todas las cámaras usan jpeg/jpg
      if (ruta.endsWith('.png')) {
        tipoMime = 'image/png';
      } else if (ruta.endsWith('.webp')) {
        tipoMime = 'image/webp';
      } else if (ruta.endsWith('.heic')) {
        tipoMime = 'image/heic'; // Formato típico de los iPhone
      }

      // Adjuntamos la foto al mensaje para Gemini
      partesPrompt.add(DataPart(tipoMime, bytesDeImagen));
    }

// 3. Comprobamos la conexión a Internet ANTES de enviar nada
    try {
      final resultado = await InternetAddress.lookup('google.com');
      if (resultado.isEmpty || resultado[0].rawAddress.isEmpty) {
        throw const SocketException('Sin internet');
      }
    } on SocketException catch (_) {
      // Si falla la prueba de internet, avisamos y cortamos la función
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes conexión a internet. Revisa tu Wi-Fi o datos móviles.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // El return hace que no se ejecute nada del código de abajo
    }

    // 4. Enviamos el paquete a Gemini (Si hemos llegado aquí, es que HAY internet)
    try {
      print("Enviando datos a Gemini...");
      
      // Avisamos al usuario de que la IA está trabajando
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La IA está leyendo tu contenido y creando las tarjetas...'), 
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 4),
        ),
      );

      // Usamos Content.multi para poder enviarle Texto + Archivo/Imagen a la vez
      final response = await model.generateContent([
        Content.multi(partesPrompt)
      ]);
      
      // ... resto de tu código igual (print, _guardarRepuestaBbdd, etc.)
      print("¡Gemini ha respondido!");
      log("Respuesta en crudo: ${response.text}");

      // Guardamos en Firebase
      if (mounted) {
        _guardarRepuestaBbdd(response.text ?? '');
      }
    } catch (e) {
      print("Error al hablar con Gemini: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error con la IA: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            // 1. Intentamos volver de forma natural (funciona si usaste Navigator.push)
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // 2. Si no hay historial, forzamos la navegación al Home
              // IMPORTANTE: Cambia "HomeScreen()" por el nombre real de tu pantalla principal
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ), // <-- PON AQUÍ TU PANTALLA
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

              // --- SELECTOR DE CARPETAS CON FIREBASE ---
              StreamBuilder<QuerySnapshot>(
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

                  // Añadimos las carpetas existentes
                  for (var doc in snapshot.data!.docs) {
                    String nombre = doc['Nombre'] ?? 'Sin nombre';
                    opciones.add(
                      DropdownMenuItem(value: nombre, child: Text(nombre)),
                    );
                  }

                  // Añadimos la opción de crear una nueva
                  opciones.add(
                    const DropdownMenuItem(
                      value: 'NUEVA',
                      child: Text(
                        '➕ Crear nueva carpeta...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
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
                        value:
                            opciones.any(
                              (item) => item.value == _carpetaSeleccionada,
                            )
                            ? _carpetaSeleccionada
                            : null,
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _carpetaSeleccionada = nuevoValor;
                            _creandoNuevaCarpeta = (nuevoValor == 'NUEVA');
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Selecciona una carpeta' : null,
                      ),

                      // Si elige crear nueva, mostramos el campo de texto
                      if (_creandoNuevaCarpeta) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _almacenController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la nueva carpeta',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.create_new_folder),
                          ),
                          validator: (value) {
                            if (_creandoNuevaCarpeta &&
                                (value == null || value.isEmpty)) {
                              return 'Escribe el nombre de la carpeta';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  );
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

              // --- BOTÓN FINAL ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true; // Empieza a cargar
                          });
                          _generarConIA().whenComplete(() {
                            setState(() {
                              _isLoading =
                                  false; // Termina de cargar pase lo que pase
                            });
                          });
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

  // --- GUARDAR EN BBDD ---
  Future<void> _guardarRepuestaBbdd(String respuestaGemini) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        print("Error: Nadie ha iniciado sesión.");
        return;
      }

      String jsonLimpio = respuestaGemini
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      print("Procesando las tarjetas...");
      List<dynamic> tarjetasGeneradas = [];

      try {
        tarjetasGeneradas = jsonDecode(jsonLimpio);
      } catch (e) {
        print("Error al decodificar el JSON de Gemini: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La IA se ha confundido con el formato. Por favor, inténtalo de nuevo.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return; // Detenemos la función aquí para que no intente subir datos rotos
      }

      String nombreCarpeta = "General";

      if (_creandoNuevaCarpeta && _almacenController.text.isNotEmpty) {
        nombreCarpeta = _almacenController.text;
      } else if (_carpetaSeleccionada != null &&
          _carpetaSeleccionada != 'NUEVA') {
        nombreCarpeta = _carpetaSeleccionada!;
      }

      final carpetaPath = FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('Carpetas');

      String carpetaDestino;

      final busqueda = await carpetaPath
          .where("Nombre", isEqualTo: nombreCarpeta)
          .get();

      if (busqueda.docs.isNotEmpty) {
        carpetaDestino = busqueda.docs.first.id;
        print("Carpeta encontrada con ID $carpetaDestino");
      } else {
        final nuevaCarpeta = await carpetaPath.add({
          "Nombre": nombreCarpeta,
          "fechaCreacion": FieldValue.serverTimestamp(),
        });
        carpetaDestino = nuevaCarpeta.id;
        print("Nueva carpeta generada con id: $carpetaDestino");
      }

      print(
        "Subiendo ${tarjetasGeneradas.length} flashcards a la base de datos...",
      );

      final flashcardsRef = carpetaPath
          .doc(carpetaDestino)
          .collection('Flashcards');

      for (var tarjeta in tarjetasGeneradas) {
        await flashcardsRef.add({
          'pregunta': tarjeta['pregunta'],
          'respuesta': tarjeta['respuesta'],
          'titulo_mazo': _tituloController.text,
          'fechaCreacion': FieldValue.serverTimestamp(),
          'nivel': 0,
        });
      }

      // 6. Mensaje de éxito y limpieza
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Flashcards creadas y guardadas con éxito! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        _tituloController.clear();
        _numTarjetasController.clear();
        _apuntesController.clear();
        if (_creandoNuevaCarpeta) {
          _almacenController.clear();
        }

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          setState(() {
            _carpetaSeleccionada = null;
            _creandoNuevaCarpeta = false;
          });
        }
      }
    } catch (e) {
      print("Error al guardar en Firebase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar o guardar las tarjetas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
