import 'package:flutter/material.dart';
import 'tela_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Fatec - Híbrido',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaSplash(),
    );
  }
}
