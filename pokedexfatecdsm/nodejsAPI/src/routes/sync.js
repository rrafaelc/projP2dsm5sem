const express = require('express');
const prisma = require('../config/database');

const router = express.Router();

// POST /api/sync/pokemon - Sincronizar pokémon (compatibilidade com PHP)
router.post('/pokemon', async (req, res) => {
  try {
    const { id, nome, tipo, imagem } = req.body;

    if (!id || !nome || !tipo || !imagem) {
      return res.status(400).json({ 
        error: 'ID, nome, tipo e imagem são obrigatórios' 
      });
    }

    // Usar upsert para criar ou atualizar
    const pokemon = await prisma.pokemon.upsert({
      where: { id: parseInt(id) },
      update: {
        nome,
        tipo,
        imagem
      },
      create: {
        id: parseInt(id),
        nome,
        tipo,
        imagem
      }
    });

    res.json({ 
      status: 'ok',
      message: 'Pokémon sincronizado com sucesso',
      pokemon
    });
  } catch (error) {
    console.error('Erro ao sincronizar pokémon:', error);
    res.status(500).json({ 
      status: 'error',
      error: 'Erro interno do servidor' 
    });
  }
});

// POST /api/sync/user - Sincronizar usuário (compatibilidade com PHP)
router.post('/user', async (req, res) => {
  try {
    const { id, email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ 
        error: 'Email e senha são obrigatórios' 
      });
    }

    let usuario;
    if (id) {
      // Usar upsert se ID for fornecido
      usuario = await prisma.usuario.upsert({
        where: { id: parseInt(id) },
        update: {
          email,
          senha
        },
        create: {
          id: parseInt(id),
          email,
          senha
        }
      });
    } else {
      // Criar novo usuário sem ID específico
      usuario = await prisma.usuario.create({
        data: {
          email,
          senha
        }
      });
    }

    res.json({ 
      status: 'ok',
      message: 'Usuário sincronizado com sucesso',
      user: {
        id: usuario.id,
        email: usuario.email
      }
    });
  } catch (error) {
    console.error('Erro ao sincronizar usuário:', error);
    res.status(500).json({ 
      status: 'error',
      error: 'Erro interno do servidor' 
    });
  }
});

// POST /api/sync/bulk - Sincronização em lote
router.post('/bulk', async (req, res) => {
  try {
    const { usuarios = [], pokemons = [] } = req.body;
    
    const resultados = {
      usuarios: [],
      pokemons: [],
      erros: []
    };

    // Sincronizar usuários
    for (const userData of usuarios) {
      try {
        const { id, email, senha } = userData;
        const usuario = await prisma.usuario.upsert({
          where: id ? { id: parseInt(id) } : { email },
          update: { email, senha },
          create: id ? { id: parseInt(id), email, senha } : { email, senha }
        });
        resultados.usuarios.push(usuario);
      } catch (error) {
        resultados.erros.push({
          tipo: 'usuario',
          dados: userData,
          erro: error.message
        });
      }
    }

    // Sincronizar pokémons
    for (const pokemonData of pokemons) {
      try {
        const { id, nome, tipo, imagem } = pokemonData;
        const pokemon = await prisma.pokemon.upsert({
          where: { id: parseInt(id) },
          update: { nome, tipo, imagem },
          create: { id: parseInt(id), nome, tipo, imagem }
        });
        resultados.pokemons.push(pokemon);
      } catch (error) {
        resultados.erros.push({
          tipo: 'pokemon',
          dados: pokemonData,
          erro: error.message
        });
      }
    }

    res.json({
      status: 'ok',
      message: 'Sincronização em lote concluída',
      resultados
    });
  } catch (error) {
    console.error('Erro na sincronização em lote:', error);
    res.status(500).json({ 
      status: 'error',
      error: 'Erro interno do servidor' 
    });
  }
});

module.exports = router;
