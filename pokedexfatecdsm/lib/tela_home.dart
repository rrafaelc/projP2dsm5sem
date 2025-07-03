import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/pokemon.dart';
import 'tela_login.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  void _logout(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.logout();

      // Navegar para tela de login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaLogin()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokémons"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: dbHelper.getPokemons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final pokemons = snapshot.data!;
          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final p = pokemons[index];
              return ListTile(
                leading: Image.asset(
                  p.imagem,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pets, color: Colors.grey),
                    );
                  },
                ),
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
