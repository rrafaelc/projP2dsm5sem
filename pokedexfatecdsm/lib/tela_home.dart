import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/pokemon.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(title: const Text("Pokémons")),
      body: FutureBuilder<List<Pokemon>>(
        future: dbHelper.getPokemons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final pokemons = snapshot.data!;
          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final p = pokemons[index];
              return ListTile(
                leading: Image.asset(p.imagem, width: 50),
                title: Text(p.nome),
                subtitle: Text(p.tipo),
              );
            },
          );
        },
      ),
    );
  }
}
