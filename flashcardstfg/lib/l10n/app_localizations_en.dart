// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tituloHome => 'My Notes';

  @override
  String get tusMazos => 'Your Decks';

  @override
  String get crearMazo => 'Create Deck';

  @override
  String get error => 'Error';

  @override
  String get errorMazos => 'You don\'t have any decks yet';

  @override
  String get cerrarSesion => 'Log out';

  @override
  String get confirmacionSesion => 'Are you sure you want to log out?';

  @override
  String get salir => 'Yes, log out';

  @override
  String get errorCerrarS => 'Warning when disconnecting Google';

  @override
  String get errorGeneralsesion => 'General error logging out';

  @override
  String get msgCardEdit => 'Edit name';

  @override
  String get msgCardDelete => 'Delete deck';

  @override
  String get mensajeEditar => 'Edit deck name';

  @override
  String get nombreMazo => 'Deck name';

  @override
  String get nombreEditado => 'Name updated successfully';

  @override
  String get errorEditar => 'Error changing name';

  @override
  String get nuevaCarpeta => 'Create new folder';

  @override
  String get seleccionCarpeta => 'Select a folder';

  @override
  String get nombreCarpeta => 'New folder\'s name';

  @override
  String get escribirnombre => 'Type the name of the folder';

  @override
  String get borrarCarpeta => 'Delete this folder?';

  @override
  String get avisoBorrar =>
      'All decks and cards it contains will be permanently lost. This action cannot be undone.';

  @override
  String get borrar => 'Yes, delete everything';

  @override
  String get confirmadoBorrado => 'Folder successfully deleted';

  @override
  String get errorBorrar => 'Error deleting folder.';

  @override
  String get configuracion => 'Settings';

  @override
  String get modoColor => 'Dark / Light Mode';

  @override
  String get idioma => 'Change language';

  @override
  String get cancelar => 'Cancel';

  @override
  String get guardar => 'Save';

  @override
  String get pregunta => 'Question';

  @override
  String get respuesta => 'Answer';

  @override
  String get texto => 'Text';

  @override
  String get imagen => 'Image';

  @override
  String get archivo => 'File';

  @override
  String get mensajeLogin => 'Your study, powered by Gemini';

  @override
  String get mensajeEntrarGoogle => 'Sign in with Google';

  @override
  String get botonPulsadoLogin => 'Button pressed, initiating login';

  @override
  String get exitoLogin => 'Login successful';

  @override
  String get errorLogin => 'Login failed or cancelled';

  @override
  String get errorSesion => 'Could not log in';

  @override
  String get errorTarjetas => 'There are no cards in this deck';

  @override
  String get tarjetas => 'Cards';

  @override
  String get tarjeta => 'Card';

  @override
  String get de => 'of';

  @override
  String get mensajeDeslizarTocar => 'Swipe to change | Tap to flip';

  @override
  String get voltear => 'Tap to flip.';

  @override
  String get crearFlashcard => 'Create Flashcards';

  @override
  String get tituloMazo => 'Deck title';

  @override
  String get errorTitulo => 'Title is required';

  @override
  String get numFlashcards => 'Number of desired Flashcards';

  @override
  String get numero => 'Enter a number';

  @override
  String get errorNum => 'Must be a valid number';

  @override
  String get pegarApuntes => 'Paste your notes here';

  @override
  String get tomarFoto => 'Take Photo or Upload Image';

  @override
  String get subirArchivo => 'Upload PDF or document';

  @override
  String get generarFlashcards => 'Generate Flashcards';

  @override
  String get errorAPI => 'API reading error';

  @override
  String get prepararArchivo => 'Preparing file';

  @override
  String get procesarImagen => 'Processing image';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get analizandoIA => 'Analyzing with Artificial Intelligence';

  @override
  String get saveFl => 'Saving Flashcards';

  @override
  String get errorIA => 'Artificial Intelligence model error';

  @override
  String get carpetaVacia => 'This folder is empty. Create some Decks';

  @override
  String get mazogenerado => 'Deck generated instantly';

  @override
  String get errorBaseDatos => 'Databases updating error';
}
