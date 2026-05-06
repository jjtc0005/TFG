import 'package:flutter/material.dart';

class HeaderSaludo extends StatelessWidget {
  final String nombreUsuario;

  const HeaderSaludo({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }
}