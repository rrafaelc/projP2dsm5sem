const axios = require('axios');

const API_BASE_URL = 'http://localhost:3000/api';

async function testAPI() {
  console.log('🧪 Testando API Pokédx Fatec DSM...\n');

  try {
    // 1. Verificar health da API
    console.log('1. 🏥 Verificando health da API...');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ API está funcionando:', healthResponse.data.message);

    // 2. Fazer login
    console.log('\n2. 👤 Fazendo login...');
    const loginResponse = await axios.post(`${API_BASE_URL}/usuarios/login`, {
      email: 'fatec@pokemon.com',
      senha: 'pikachu'
    });
    const token = loginResponse.data.token;
    console.log('✅ Login realizado com sucesso!');
    console.log('   Token:', token.substring(0, 20) + '...');

    // Headers com token
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // 3. Listar pokémons
    console.log('\n3. 🐾 Listando pokémons...');
    const pokemonsResponse = await axios.get(`${API_BASE_URL}/pokemons`, { headers });
    console.log('✅ Pokémons encontrados:', pokemonsResponse.data.pokemons.length);
    pokemonsResponse.data.pokemons.slice(0, 3).forEach(pokemon => {
      console.log(`   - ${pokemon.nome} (${pokemon.tipo})`);
    });

    // 4. Buscar pokémon específico
    console.log('\n4. 🔍 Buscando Pikachu... (se existir)');
    try {
      const pikachuResponse = await axios.get(`${API_BASE_URL}/pokemons/search/Pikachu`, { headers });
      if (pikachuResponse.data.length > 0) {
        console.log('✅ Pikachu encontrado!');
      } else {
        console.log('⚠️ Pikachu não encontrado (normal, não está nos dados iniciais)');
      }
    } catch (error) {
      console.log('⚠️ Pikachu não encontrado');
    }

    // 5. Buscar Bulbasaur por ID
    console.log('\n5. 🌱 Buscando Bulbasaur por ID (1)...');
    const bulbasaurResponse = await axios.get(`${API_BASE_URL}/pokemons/1`, { headers });
    console.log('✅ Encontrado:', bulbasaurResponse.data.nome);

    // 6. Criar novo pokémon (teste)
    console.log('\n6. ➕ Criando novo pokémon (Pikachu)...');
    try {
      const newPokemonResponse = await axios.post(`${API_BASE_URL}/pokemons`, {
        id: 25,
        nome: 'Pikachu',
        tipo: 'Electric',
        imagem: 'pikachu.png'
      }, { headers });
      console.log('✅ Pikachu criado com sucesso!');
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️ Pikachu já existe (isso é normal se já foi criado antes)');
      } else {
        console.log('❌ Erro ao criar Pikachu:', error.response?.data?.error || error.message);
      }
    }

    // 7. Listar usuários (sem senhas)
    console.log('\n7. 👥 Listando usuários...');
    const usuariosResponse = await axios.get(`${API_BASE_URL}/usuarios`, { headers });
    console.log('✅ Usuários encontrados:', usuariosResponse.data.length);
    usuariosResponse.data.forEach(usuario => {
      console.log(`   - ${usuario.email} (ID: ${usuario.id})`);
    });

    // 8. Teste de sincronização
    console.log('\n8. 🔄 Testando endpoint de sincronização...');
    const syncResponse = await axios.post(`${API_BASE_URL}/sync/pokemon`, {
      id: 26,
      nome: 'Raichu',
      tipo: 'Electric',
      imagem: 'raichu.png'
    });
    console.log('✅ Sincronização realizada:', syncResponse.data.status);

    console.log('\n🎉 Todos os testes passaram com sucesso!');

  } catch (error) {
    console.error('❌ Erro durante os testes:');
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Dados:', error.response.data);
    } else {
      console.error('   Mensagem:', error.message);
    }
    console.log('\n💡 Dicas:');
    console.log('   - Certifique-se de que a API está rodando (npm run dev)');
    console.log('   - Verifique se o PostgreSQL está funcionando');
    console.log('   - Execute o seed (npm run seed) se necessário');
  }
}

// Executar teste se o arquivo for chamado diretamente
if (require.main === module) {
  testAPI();
}

module.exports = testAPI;
