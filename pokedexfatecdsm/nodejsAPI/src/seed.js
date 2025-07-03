const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function seed() {
  console.log('🌱 Iniciando seed do banco de dados...');

  try {
    // Limpar dados existentes
    console.log('🧹 Limpando dados existentes...');
    await prisma.pokemon.deleteMany({});
    await prisma.usuario.deleteMany({});

    // Seed do usuário padrão
    console.log('👤 Criando usuário padrão...');
    const senhaHash = await bcrypt.hash('pikachu', 10);
    
    const usuario = await prisma.usuario.create({
      data: {
        email: 'fatec@pokemon.com',
        senha: senhaHash
      }
    });

    console.log(`✅ Usuário criado: ${usuario.email} (ID: ${usuario.id})`);

    // Seed dos pokémons
    console.log('🐾 Criando pokémons...');
    
    const pokemons = [
      { id: 1, nome: 'Bulbasaur', tipo: 'Grass/Poison', imagem: 'assets/images/bulbasaur.png' },
      { id: 2, nome: 'Ivysaur', tipo: 'Grass/Poison', imagem: 'assets/images/ivysaur.png' },
      { id: 3, nome: 'Venusaur', tipo: 'Grass/Poison', imagem: 'assets/images/venusaur.png' },
      { id: 4, nome: 'Charmander', tipo: 'Fire', imagem: 'assets/images/charmander.png' },
      { id: 5, nome: 'Charmeleon', tipo: 'Fire', imagem: 'assets/images/charmeleon.png' },
      { id: 6, nome: 'Charizard', tipo: 'Fire/Flying', imagem: 'assets/images/charizard.png' },
      { id: 7, nome: 'Squirtle', tipo: 'Water', imagem: 'assets/images/squirtle.png' },
      { id: 8, nome: 'Wartortle', tipo: 'Water', imagem: 'assets/images/wartortle.png' },
      { id: 9, nome: 'Blastoise', tipo: 'Water', imagem: 'assets/images/blastoise.png' },
      { id: 10, nome: 'Caterpie', tipo: 'Bug', imagem: 'assets/images/caterpie.png' }
    ];

    const pokemonsCriados = await prisma.pokemon.createMany({
      data: pokemons
    });

    console.log(`✅ ${pokemonsCriados.count} pokémons criados com sucesso!`);

    // Verificar dados criados
    const totalUsuarios = await prisma.usuario.count();
    const totalPokemons = await prisma.pokemon.count();

    console.log('\n📊 Resumo do seed:');
    console.log(`👥 Usuários: ${totalUsuarios}`);
    console.log(`🐾 Pokémons: ${totalPokemons}`);
    console.log('\n🎉 Seed concluído com sucesso!');

  } catch (error) {
    console.error('❌ Erro durante o seed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Executar seed se o arquivo for chamado diretamente
if (require.main === module) {
  seed();
}

module.exports = seed;
