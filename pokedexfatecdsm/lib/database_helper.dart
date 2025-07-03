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
      print('🔐 Tentando login com: $email');
      print('🌐 URL: $_baseUrl/usuarios/login');

      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken(data['token']);

        print('✅ Login realizado com sucesso!');
        return Usuario(
          id: data['user']['id'],
          email: data['user']['email'],
          senha: senha,
        );
      } else if (response.statusCode == 401) {
        print('❌ Credenciais inválidas');
        return null;
      } else {
        print('❌ Erro no servidor: ${response.statusCode}');
        print('📄 Detalhes: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception ao autenticar usuário: $e');
      print('🔍 Tipo da exception: ${e.runtimeType}');

      // Verificar se é erro de conexão
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException')) {
        print('🌐 Erro de conexão - Verifique se a API está rodando');
      }

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
                imagem: _normalizarCaminhoImagem(e['imagem'] as String),
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
          imagem: _normalizarCaminhoImagem(data['imagem'] as String),
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
                imagem: _normalizarCaminhoImagem(e['imagem'] as String),
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
      print('🔍 Testando conectividade com a API...');
      print('🌐 URL de teste: http://localhost:3000/health');

      final response = await http
          .get(Uri.parse('http://localhost:3000/health'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      print('📊 Status da API: ${response.statusCode}');
      print('📝 Resposta: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ API está funcionando!');
        return true;
      } else {
        print('❌ API retornou erro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Erro ao conectar com a API: $e');
      print('🔍 Tipo do erro: ${e.runtimeType}');

      if (e.toString().contains('TimeoutException')) {
        print('⏰ Timeout - API pode estar lenta ou não disponível');
      } else if (e.toString().contains('Failed host lookup')) {
        print('🌐 Erro de DNS - Verifique o IP da API');
      } else if (e.toString().contains('Connection refused')) {
        print('🚫 Conexão recusada - API pode não estar rodando');
      }

      return false;
    }
  }

  // Testar login com verificação de conectividade
  Future<Usuario?> testLogin() async {
    print('🧪 Iniciando teste de login...');

    // Primeiro, testar conectividade
    final isConnected = await isApiAvailable();
    if (!isConnected) {
      print('❌ Não foi possível conectar com a API');
      return null;
    }

    // Tentar login com credenciais padrão
    return await getUser('fatec@pokemon.com', 'pikachu');
  }

  // Limpar token (logout)
  void clearToken() {
    _token = null;
  }

  // Normalizar caminho da imagem para garantir compatibilidade
  String _normalizarCaminhoImagem(String imagem) {
    // Se já tem o caminho completo, retorna como está
    if (imagem.startsWith('assets/images/')) {
      return imagem;
    }

    // Se tem apenas o nome do arquivo, adiciona o caminho
    if (!imagem.contains('/')) {
      return 'assets/images/$imagem';
    }

    // Se tem caminho mas não começa com assets/images/, corrige
    if (imagem.contains('/') && !imagem.startsWith('assets/')) {
      final nomeArquivo = imagem.split('/').last;
      return 'assets/images/$nomeArquivo';
    }

    return imagem;
  }
}
