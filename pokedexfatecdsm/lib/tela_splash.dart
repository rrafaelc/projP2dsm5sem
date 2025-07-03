import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'tela_login.dart';
import 'tela_home.dart';

class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _verificarLogin();
  }

  Future<void> _verificarLogin() async {
    try {
      print('🔍 Verificando se há usuário logado...');

      // Aguardar um momento para mostrar o splash
      await Future.delayed(const Duration(seconds: 2));

      // Verificar se há usuário logado no cache
      final usuario = await _dbHelper.getLoggedUser();

      if (usuario != null) {
        print('✅ Usuário encontrado: ${usuario.email}');
        print('🏠 Navegando para tela home...');

        // Usuário encontrado, ir para tela home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TelaHome()),
          );
        }
      } else {
        print('❌ Nenhum usuário logado encontrado');
        print('🔐 Navegando para tela de login...');

        // Nenhum usuário logado, ir para tela de login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TelaLogin()),
          );
        }
      }
    } catch (e) {
      print('💥 Erro na verificação de login: $e');

      // Em caso de erro, ir para tela de login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TelaLogin()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone do app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            // Nome do app
            const Text(
              'Pokédex Fatec DSM',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Subtítulo
            const Text(
              'Arquitetura Híbrida',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),

            // Indicador de carregamento
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),

            // Texto de carregamento
            const Text(
              'Verificando login...',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
