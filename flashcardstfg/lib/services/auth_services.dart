import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {

      const String webClientid =
          "607082432922-4r419edu0h5mn6jginlfeshnr9qe4g9m.apps.googleusercontent.com";

      await _googleSignIn.initialize(serverClientId: webClientid);

      // 1. Lanzamos la ventana de Google
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      // 2. Obtenemos los tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // 5. Guardar usuario en Firestore
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
