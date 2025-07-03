import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/usuario.dart';
import 'models/pokemon.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // URL base da API Node.js (para login e sincronização)
  static const String _baseUrl = 'http://localhost:3000/api';

  // Headers padrão para requisições
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  String? _token; // Token JWT para autenticação
  Database? _db; // Banco SQLite local

  // === CONFIGURAÇÃO DO BANCO SQLITE LOCAL ===

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pokedex_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('🗄️ Criando banco SQLite local...');

        // Tabela de usuários (para cache do usuário logado)
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY,
            email TEXT UNIQUE,
            senha TEXT,
            token TEXT,
            synced_at TEXT
          )
        ''');

        // Tabela de pokémons (dados offline)
        await db.execute('''
          CREATE TABLE pokemons (
            id INTEGER PRIMARY KEY,
            nome TEXT,
            tipo TEXT,
            imagem TEXT,
            synced_at TEXT
          )
        ''');

        print('✅ Banco SQLite criado com sucesso!');
      },
    );
  }

  // === AUTENTICAÇÃO E GESTÃO DE TOKEN ===

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(_headers);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  void clearToken() {
    _token = null;
  }

  // === LOGIN E CACHE DE USUÁRIO ===

  // Autenticar usuário via API e salvar no cache local
  Future<Usuario?> getUser(String email, String senha) async {
    try {
      print('🔐 Tentando login via API com: $email');

      // Primeiro, tentar login via API
      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      print('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        setToken(token);

        final usuario = Usuario(
          id: userData['id'],
          email: userData['email'],
          senha: senha,
        );

        // Salvar usuário no cache local
        await _salvarUsuarioLocal(usuario, token);

        // Sincronizar pokémons após login bem-sucedido
        await sincronizarPokemons();

        print('✅ Login realizado com sucesso!');
        return usuario;
      } else {
        print('❌ Login falhou via API');

        // Tentar buscar usuário no cache local (modo offline)
        return await _buscarUsuarioLocal(email, senha);
      }
    } catch (e) {
      print('💥 Erro na API: $e');
      print('🔄 Tentando modo offline...');

      // Em caso de erro de conexão, tentar modo offline
      return await _buscarUsuarioLocal(email, senha);
    }
  }

  // Salvar usuário no SQLite local
  Future<void> _salvarUsuarioLocal(Usuario usuario, String token) async {
    final db = await database;
    await db.insert('usuarios', {
      'id': usuario.id,
      'email': usuario.email,
      'senha': usuario.senha,
      'token': token,
      'synced_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    print('💾 Usuário salvo no cache local');
  }

  // Buscar usuário no SQLite local (modo offline)
  Future<Usuario?> _buscarUsuarioLocal(String email, String senha) async {
    try {
      final db = await database;
      final result = await db.query(
        'usuarios',
        where: 'email = ? AND senha = ?',
        whereArgs: [email, senha],
      );

      if (result.isNotEmpty) {
        final userData = result.first;
        _token = userData['token'] as String?;

        print('✅ Login offline realizado com sucesso!');
        return Usuario(id: userData['id'] as int, email: email, senha: senha);
      }

      print('❌ Usuário não encontrado no cache local');
      return null;
    } catch (e) {
      print('💥 Erro ao buscar usuário local: $e');
      return null;
    }
  }

  // === GESTÃO DE POKÉMONS (SQLITE LOCAL) ===

  // Buscar todos os pokémons do SQLite local
  Future<List<Pokemon>> getPokemons() async {
    try {
      final db = await database;
      final result = await db.query('pokemons', orderBy: 'id ASC');

      if (result.isEmpty) {
        print('📦 Cache local vazio, tentando sincronizar...');
        await sincronizarPokemons();

        // Tentar novamente após sincronização
        final newResult = await db.query('pokemons', orderBy: 'id ASC');
        return _mapearPokemons(newResult);
      }

      return _mapearPokemons(result);
    } catch (e) {
      print('Erro ao buscar pokémons locais: $e');
      return [];
    }
  }

  // Buscar pokémon por ID no SQLite local
  Future<Pokemon?> getPokemon(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'pokemons',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final data = result.first;
        return Pokemon(
          id: data['id'] as int,
          nome: data['nome'] as String,
          tipo: data['tipo'] as String,
          imagem: data['imagem'] as String,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pokémon local: $e');
      return null;
    }
  }

  // Buscar pokémons por nome no SQLite local
  Future<List<Pokemon>> searchPokemonsByName(String nome) async {
    try {
      final db = await database;
      final result = await db.query(
        'pokemons',
        where: 'nome LIKE ?',
        whereArgs: ['%$nome%'],
        orderBy: 'id ASC',
      );

      return _mapearPokemons(result);
    } catch (e) {
      print('Erro ao buscar pokémons por nome: $e');
      return [];
    }
  }

  // Mapear resultados do SQLite para objetos Pokemon
  List<Pokemon> _mapearPokemons(List<Map<String, dynamic>> resultados) {
    return resultados
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

  // === SINCRONIZAÇÃO COM A API ===

  // Sincronizar pokémons da API para o SQLite local
  Future<bool> sincronizarPokemons() async {
    try {
      print('🔄 Iniciando sincronização de pokémons...');

      if (!await isApiAvailable()) {
        print('⚠️ API não disponível, usando dados locais');
        return false;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/pokemons'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> pokemonsList = data['pokemons'] ?? data;

        final db = await database;
        final batch = db.batch();

        // Limpar dados antigos
        batch.delete('pokemons');

        // Inserir novos dados
        for (final pokemonData in pokemonsList) {
          batch.insert('pokemons', {
            'id': pokemonData['id'],
            'nome': pokemonData['nome'],
            'tipo': pokemonData['tipo'],
            'imagem': pokemonData['imagem'],
            'synced_at': DateTime.now().toIso8601String(),
          });
        }

        await batch.commit();

        print('✅ ${pokemonsList.length} pokémons sincronizados!');
        return true;
      } else {
        print('❌ Erro na sincronização: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Erro na sincronização: $e');
      return false;
    }
  }

  // === OPERAÇÕES OFFLINE (CRUD LOCAL) ===

  // Criar novo pokémon no SQLite local
  Future<bool> createPokemon(Pokemon pokemon) async {
    try {
      final db = await database;
      await db.insert('pokemons', {
        'id': pokemon.id,
        'nome': pokemon.nome,
        'tipo': pokemon.tipo,
        'imagem': pokemon.imagem,
        'synced_at': DateTime.now().toIso8601String(),
      });

      // Tentar sincronizar com a API se disponível
      if (await isApiAvailable()) {
        await _enviarPokemonParaAPI(pokemon);
      }

      return true;
    } catch (e) {
      print('Erro ao criar pokémon local: $e');
      return false;
    }
  }

  // Atualizar pokémon no SQLite local
  Future<bool> updatePokemon(Pokemon pokemon) async {
    try {
      final db = await database;
      await db.update(
        'pokemons',
        {
          'nome': pokemon.nome,
          'tipo': pokemon.tipo,
          'imagem': pokemon.imagem,
          'synced_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [pokemon.id],
      );

      // Tentar sincronizar com a API se disponível
      if (await isApiAvailable()) {
        await _atualizarPokemonNaAPI(pokemon);
      }

      return true;
    } catch (e) {
      print('Erro ao atualizar pokémon local: $e');
      return false;
    }
  }

  // Deletar pokémon do SQLite local
  Future<bool> deletePokemon(int id) async {
    try {
      final db = await database;
      await db.delete('pokemons', where: 'id = ?', whereArgs: [id]);

      // Tentar deletar da API se disponível
      if (await isApiAvailable()) {
        await _deletarPokemonDaAPI(id);
      }

      return true;
    } catch (e) {
      print('Erro ao deletar pokémon local: $e');
      return false;
    }
  }

  // === MÉTODOS AUXILIARES PARA SINCRONIZAÇÃO ===

  Future<void> _enviarPokemonParaAPI(Pokemon pokemon) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/pokemons'),
        headers: _getHeaders(),
        body: jsonEncode(pokemon.toMap()),
      );
    } catch (e) {
      print('Erro ao enviar pokémon para API: $e');
    }
  }

  Future<void> _atualizarPokemonNaAPI(Pokemon pokemon) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/pokemons/${pokemon.id}'),
        headers: _getHeaders(),
        body: jsonEncode(pokemon.toMap()),
      );
    } catch (e) {
      print('Erro ao atualizar pokémon na API: $e');
    }
  }

  Future<void> _deletarPokemonDaAPI(int id) async {
    try {
      await http.delete(
        Uri.parse('$_baseUrl/pokemons/$id'),
        headers: _getHeaders(),
      );
    } catch (e) {
      print('Erro ao deletar pokémon da API: $e');
    }
  }

  // === VERIFICAÇÃO DE CONECTIVIDADE ===

  Future<bool> isApiAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/health'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // === MÉTODOS LEGADOS PARA COMPATIBILIDADE ===

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

  Future<void> syncToServer() async {
    await sincronizarPokemons();
  }

  Future<void> syncToMySQL() async {
    await sincronizarPokemons();
  }

  // === MÉTODO DE TESTE ===

  Future<Usuario?> testLogin() async {
    print('🧪 Iniciando teste de login...');

    final isConnected = await isApiAvailable();
    if (isConnected) {
      print('✅ API disponível');
    } else {
      print('⚠️ API indisponível - modo offline');
    }

    return await getUser('fatec@pokemon.com', 'pikachu');
  }
}
