import 'package:flutter/material.dart';
import 'database_helper.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _resultado = 'Pressione o botão para testar a API';
  bool _testando = false;

  Future<void> _testarAPI() async {
    setState(() {
      _testando = true;
      _resultado = 'Testando conectividade...';
    });

    try {
      // 1. Testar conectividade
      print('=== INICIANDO TESTE DA API ===');
      bool apiDisponivel = await _dbHelper.isApiAvailable();

      if (!apiDisponivel) {
        setState(() {
          _resultado =
              '❌ API não está disponível!\n'
              'Verifique se a API está rodando em http://localhost:3000';
          _testando = false;
        });
        return;
      }

      setState(() {
        _resultado = '✅ API disponível!\nTestando login...';
      });

      // 2. Testar login
      final usuario = await _dbHelper.getUser('fatec@pokemon.com', 'pikachu');

      if (usuario != null) {
        setState(() {
          _resultado =
              '✅ Login realizado com sucesso!\n'
              'Usuário: ${usuario.email}\n'
              'ID: ${usuario.id}\n\n'
              'Testando pokémons...';
        });

        // 3. Testar busca de pokémons
        final pokemons = await _dbHelper.getPokemons();

        setState(() {
          _resultado =
              '🎉 TESTE COMPLETO COM SUCESSO!\n\n'
                  '✅ API: Funcionando\n'
                  '✅ Login: ${usuario.email}\n'
                  '✅ Pokémons: ${pokemons.length} encontrados\n\n'
                  'Primeiros pokémons:\n' +
              pokemons.take(5).map((p) => '• ${p.nome} (${p.tipo})').join('\n');
        });
      } else {
        setState(() {
          _resultado =
              '❌ Falha no login!\n'
              'Verifique as credenciais ou a conexão com a API';
        });
      }
    } catch (e) {
      setState(() {
        _resultado =
            '💥 ERRO: $e\n\n'
            'Verifique:\n'
            '• Se a API está rodando (npm run dev)\n'
            '• Se o banco PostgreSQL está conectado\n'
            '• Se as permissões de rede estão configuradas';
      });
    }

    setState(() {
      _testando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste da API'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teste de Conectividade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Este teste vai verificar:\n'
                      '• Conectividade com a API\n'
                      '• Login com usuário padrão\n'
                      '• Busca de pokémons',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testando ? null : _testarAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _testando
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Testando...'),
                      ],
                    )
                  : const Text(
                      'TESTAR API',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _resultado,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
