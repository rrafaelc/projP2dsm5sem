import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'tela_home.dart';
import 'test_api_screen.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('🔐 Iniciando login...');
        final user = await dbHelper.getUser(
          _emailController.text,
          _passController.text,
        );

        if (user != null) {
          print('✅ Login realizado com sucesso!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TelaHome()),
          );
        } else {
          print('❌ Login falhou - usuário não encontrado');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login inválido - verifique email e senha'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('💥 Erro durante o login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _testarAPI() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TestApiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.contains('@') ? null : "Email inválido",
              ),
              TextFormField(
                controller: _passController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Senha obrigatória" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text("Entrar")),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _testarAPI,
                child: const Text(
                  "🧪 Testar API",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "📝 Dados para teste:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Email: fatec@pokemon.com\nSenha: pikachu",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
