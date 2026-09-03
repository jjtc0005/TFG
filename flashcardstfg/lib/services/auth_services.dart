import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {

      final String? webClientid = dotenv.env['GOOGLE_CLIENT_ID'];

      if (webClientid == null || webClientid.isEmpty) {
        print("Error crítico: GOOGLE_CLIENT_ID no configurado en apiKey.env");
        return null;
      }

      await _googleSignIn.initialize(serverClientId: webClientid);

      // Lanzamos la ventana de Google
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      // Obtenemos los tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Guardar usuario en Firestore
      if (userCredential.user != null) {
        await _guardarUsuario(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("Error en el login de Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _guardarUsuario(User user) async {
    try {
      final docUser = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final Map<String, dynamic> datosUsuario = {
        'email': user.email,
        'nombre': user.displayName ?? 'Usuario sin nombre', 
        'foto': user.photoURL ?? null,
        'ultima_conexion': FieldValue.serverTimestamp(),
      };
      await docUser.set(datosUsuario, SetOptions(merge: true));
    } catch (e) {
      print("Error guardando usuario: $e");
    }
  }
}
