const axios = require('axios');

const API_BASE_URL = 'http://localhost:3000/api';

async function testImages() {
  console.log('🖼️ Testando caminhos das imagens...\n');

  try {
    // Fazer login
    const loginResponse = await axios.post(`${API_BASE_URL}/usuarios/login`, {
      email: 'fatec@pokemon.com',
      senha: 'pikachu'
    });
    const token = loginResponse.data.token;

    // Headers com token
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // Buscar pokémons
    const pokemonsResponse = await axios.get(`${API_BASE_URL}/pokemons`, { headers });
    const pokemons = pokemonsResponse.data.pokemons || pokemonsResponse.data;

    console.log('📊 Caminhos das imagens encontrados:');
    pokemons.forEach(pokemon => {
      console.log(`   ${pokemon.nome}: "${pokemon.imagem}"`);
    });

    // Verificar se todos têm o caminho correto
    const problemaPaths = pokemons.filter(p => !p.imagem.startsWith('assets/images/'));
    
    if (problemaPaths.length > 0) {
      console.log('\n❌ Problemas encontrados:');
      problemaPaths.forEach(p => {
        console.log(`   ${p.nome}: "${p.imagem}" (deveria começar com "assets/images/")`);
      });
    } else {
      console.log('\n✅ Todos os caminhos estão corretos!');
    }

  } catch (error) {
    console.error('❌ Erro:', error.response?.data || error.message);
  }
}

testImages();
