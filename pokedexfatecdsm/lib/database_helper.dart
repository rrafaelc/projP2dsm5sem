import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/usuario.dart';
import 'models/pokemon.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // URL base da API Node.js
  static const String _baseUrl = 'http://localhost:3000/api';

  // Headers padrão para requisições
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  String? _token; // Token JWT para autenticação

  // Definir token de autenticação
  void setToken(String token) {
    _token = token;
  }

  // Obter headers com token se disponível
  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(_headers);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Autenticar usuário
  Future<Usuario?> getUser(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken(data['token']);

        return Usuario(
          id: data['user']['id'],
          email: data['user']['email'],
          senha: senha,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao autenticar usuário: $e');
      return null;
    }
  }

  // Buscar todos os pokémons
  Future<List<Pokemon>> getPokemons() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemons'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> pokemonsList = data['pokemons'] ?? data;

        return pokemonsList
            .map(
              (e) => Pokemon(
                id: e['id'] as int,
                nome: e['nome'] as String,
                tipo: e['tipo'] as String,
                imagem: e['imagem'] as String,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pokémons: $e');
      return [];
    }
  }

  // Buscar pokémon por ID
  Future<Pokemon?> getPokemon(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemons/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Pokemon(
          id: data['id'] as int,
          nome: data['nome'] as String,
          tipo: data['tipo'] as String,
          imagem: data['imagem'] as String,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pokémon: $e');
      return null;
    }
  }

  // Buscar pokémons por nome
  Future<List<Pokemon>> searchPokemonsByName(String nome) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemons/search/$nome'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> pokemonsList = jsonDecode(response.body);
        return pokemonsList
            .map(
              (e) => Pokemon(
                id: e['id'] as int,
                nome: e['nome'] as String,
                tipo: e['tipo'] as String,
                imagem: e['imagem'] as String,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pokémons por nome: $e');
      return [];
    }
  }

  // Criar novo usuário
  Future<bool> createUser(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios'),
        headers: _headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return false;
    }
  }

  // Criar novo pokémon
  Future<bool> createPokemon(Pokemon pokemon) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/pokemons'),
        headers: _getHeaders(),
        body: jsonEncode(pokemon.toMap()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro ao criar pokémon: $e');
      return false;
    }
  }

  // Atualizar pokémon
  Future<bool> updatePokemon(Pokemon pokemon) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/pokemons/${pokemon.id}'),
        headers: _getHeaders(),
        body: jsonEncode(pokemon.toMap()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar pokémon: $e');
      return false;
    }
  }

  // Deletar pokémon
  Future<bool> deletePokemon(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/pokemons/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar pokémon: $e');
      return false;
    }
  }

  // Sincronizar com servidor (mantido para compatibilidade)
  Future<void> syncToServer() async {
    try {
      // Esta função agora pode ser usada para sincronizar dados offline
      // ou realizar outras operações de sincronização se necessário
      print('Sincronização iniciada...');

      // Como agora trabalhamos diretamente com a API,
      // a sincronização é automática a cada operação
      print('Sincronização concluída!');
    } catch (e) {
      print('Erro na sincronização: $e');
    }
  }

  // Método legado mantido para compatibilidade
  Future<void> syncToMySQL() async {
    await syncToServer();
  }

  // Verificar conectividade com a API
  Future<bool> isApiAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/../health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API não disponível: $e');
      return false;
    }
  }

  // Limpar token (logout)
  void clearToken() {
    _token = null;
  }
}
