import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HeaderSaludo extends StatelessWidget {
  final User? user;

  const HeaderSaludo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          if (user?.photoURL != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user!.photoURL!),
            )
          else
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${user?.displayName?.split(' ').first ?? 'Estudiante'}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '¿Qué vamos a estudiar hoy?',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}