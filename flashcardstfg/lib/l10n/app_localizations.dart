import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @tituloHome.
  ///
  /// In es, this message translates to:
  /// **'Mis Apuntes'**
  String get tituloHome;

  /// No description provided for @tusMazos.
  ///
  /// In es, this message translates to:
  /// **'Tus Mazos'**
  String get tusMazos;

  /// No description provided for @crearMazo.
  ///
  /// In es, this message translates to:
  /// **'Crear Mazo'**
  String get crearMazo;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorMazos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes mazos'**
  String get errorMazos;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @confirmacionSesion.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quiere salir?'**
  String get confirmacionSesion;

  /// No description provided for @salir.
  ///
  /// In es, this message translates to:
  /// **'Sí salir'**
  String get salir;

  /// No description provided for @errorCerrarS.
  ///
  /// In es, this message translates to:
  /// **'Aviso al desconectar Google'**
  String get errorCerrarS;

  /// No description provided for @errorGeneralsesion.
  ///
  /// In es, this message translates to:
  /// **'Error general cerrando sesión'**
  String get errorGeneralsesion;

  /// No description provided for @msgCardEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get msgCardEdit;

  /// No description provided for @msgCardDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mazo'**
  String get msgCardDelete;

  /// No description provided for @mensajeEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre del mazo'**
  String get mensajeEditar;

  /// No description provided for @nombreMazo.
  ///
  /// In es, this message translates to:
  /// **'Nombre del mazo'**
  String get nombreMazo;

  /// No description provided for @nombreEditado.
  ///
  /// In es, this message translates to:
  /// **'Nombre actualizado correctamente'**
  String get nombreEditado;

  /// No description provided for @errorEditar.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar el nombre'**
  String get errorEditar;

  /// No description provided for @nuevaCarpeta.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva carpeta'**
  String get nuevaCarpeta;

  /// No description provided for @seleccionCarpeta.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una carpeta'**
  String get seleccionCarpeta;

  /// No description provided for @nombreCarpeta.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la nueva carpeta'**
  String get nombreCarpeta;

  /// No description provided for @escribirnombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de la carpeta'**
  String get escribirnombre;

  /// No description provided for @borrarCarpeta.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta carpeta?'**
  String get borrarCarpeta;

  /// No description provided for @avisoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Se perderán todos los mazos y tarjetas que contenga permanentemente. Esta acción no se puede deshacer.'**
  String get avisoBorrar;

  /// No description provided for @borrar.
  ///
  /// In es, this message translates to:
  /// **'Sí, borrar Todo'**
  String get borrar;

  /// No description provided for @confirmadoBorrado.
  ///
  /// In es, this message translates to:
  /// **'Carpeta borrada limpiamente'**
  String get confirmadoBorrado;

  /// No description provided for @errorBorrar.
  ///
  /// In es, this message translates to:
  /// **'Error al borrar la carpeta.'**
  String get errorBorrar;

  /// No description provided for @configuracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuracion;

  /// No description provided for @modoColor.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro / Claro'**
  String get modoColor;

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get idioma;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @pregunta.
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get pregunta;

  /// No description provided for @respuesta.
  ///
  /// In es, this message translates to:
  /// **'Respuesta'**
  String get respuesta;

  /// No description provided for @texto.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get texto;

  /// No description provided for @imagen.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get imagen;

  /// No description provided for @archivo.
  ///
  /// In es, this message translates to:
  /// **'Archivo'**
  String get archivo;

  /// No description provided for @mensajeLogin.
  ///
  /// In es, this message translates to:
  /// **'Tu estudio, potenciado por Gemini'**
  String get mensajeLogin;

  /// No description provided for @mensajeEntrarGoogle.
  ///
  /// In es, this message translates to:
  /// **'Entrar con Google'**
  String get mensajeEntrarGoogle;

  /// No description provided for @botonPulsadoLogin.
  ///
  /// In es, this message translates to:
  /// **'Botón pulsado, iniciando Login'**
  String get botonPulsadoLogin;

  /// No description provided for @exitoLogin.
  ///
  /// In es, this message translates to:
  /// **'Login con éxito'**
  String get exitoLogin;

  /// No description provided for @errorLogin.
  ///
  /// In es, this message translates to:
  /// **'Login fallido o cancelado'**
  String get errorLogin;

  /// No description provided for @errorSesion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo inciar sesión'**
  String get errorSesion;

  /// No description provided for @errorTarjetas.
  ///
  /// In es, this message translates to:
  /// **'No hay tarjetas en este mazo'**
  String get errorTarjetas;

  /// No description provided for @tarjetas.
  ///
  /// In es, this message translates to:
  /// **'tarjetas'**
  String get tarjetas;

  /// No description provided for @tarjeta.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get tarjeta;

  /// No description provided for @de.
  ///
  /// In es, this message translates to:
  /// **'de'**
  String get de;

  /// No description provided for @mensajeDeslizarTocar.
  ///
  /// In es, this message translates to:
  /// **'Desliza para cambiar | Toca para girar'**
  String get mensajeDeslizarTocar;

  /// No description provided for @voltear.
  ///
  /// In es, this message translates to:
  /// **'Toca para voltear.'**
  String get voltear;

  /// No description provided for @crearFlashcard.
  ///
  /// In es, this message translates to:
  /// **'Crear Flashcards'**
  String get crearFlashcard;

  /// No description provided for @tituloMazo.
  ///
  /// In es, this message translates to:
  /// **'Título del mazo'**
  String get tituloMazo;

  /// No description provided for @errorTitulo.
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get errorTitulo;

  /// No description provided for @numFlashcards.
  ///
  /// In es, this message translates to:
  /// **'Número de Flashcards deseadas'**
  String get numFlashcards;

  /// No description provided for @numero.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número'**
  String get numero;

  /// No description provided for @errorNum.
  ///
  /// In es, this message translates to:
  /// **'Debe ser un número válido'**
  String get errorNum;

  /// No description provided for @pegarApuntes.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí tus apuntes'**
  String get pegarApuntes;

  /// No description provided for @tomarFoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar Foto o Subir Imagen'**
  String get tomarFoto;

  /// No description provided for @subirArchivo.
  ///
  /// In es, this message translates to:
  /// **'Subir PDF o documento'**
  String get subirArchivo;

  /// No description provided for @generarFlashcards.
  ///
  /// In es, this message translates to:
  /// **'Generar Flashcards'**
  String get generarFlashcards;

  /// No description provided for @errorAPI.
  ///
  /// In es, this message translates to:
  /// **'Error en la lectura de la API'**
  String get errorAPI;

  /// No description provided for @prepararArchivo.
  ///
  /// In es, this message translates to:
  /// **'Preparando archivo'**
  String get prepararArchivo;

  /// No description provided for @procesarImagen.
  ///
  /// In es, this message translates to:
  /// **'Procesando imagen'**
  String get procesarImagen;

  /// No description provided for @noInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get noInternet;

  /// No description provided for @analizandoIA.
  ///
  /// In es, this message translates to:
  /// **'Analizando con Inteligencia Artificial'**
  String get analizandoIA;

  /// No description provided for @saveFl.
  ///
  /// In es, this message translates to:
  /// **'Guardando Flashcards'**
  String get saveFl;

  /// No description provided for @errorIA.
  ///
  /// In es, this message translates to:
  /// **'Error del modelo de Inteligencia Artificial'**
  String get errorIA;

  /// No description provided for @carpetaVacia.
  ///
  /// In es, this message translates to:
  /// **'Esta carpeta está vacía. Crea algunos mazos'**
  String get carpetaVacia;

  /// No description provided for @mazogenerado.
  ///
  /// In es, this message translates to:
  /// **'Mazo generado al instante'**
  String get mazogenerado;

  /// No description provided for @errorBaseDatos.
  ///
  /// In es, this message translates to:
  /// **'Error en la subida a la base de datos'**
  String get errorBaseDatos;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
