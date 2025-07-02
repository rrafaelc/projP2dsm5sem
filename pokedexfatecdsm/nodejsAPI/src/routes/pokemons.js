const express = require('express');
const prisma = require('../config/database');

const router = express.Router();

// GET /api/pokemons - Listar todos os pokémons
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 10, tipo } = req.query;
    const skip = (page - 1) * limit;

    const where = {};
    if (tipo) {
      where.tipo = {
        contains: tipo,
        mode: 'insensitive'
      };
    }

    const [pokemons, total] = await Promise.all([
      prisma.pokemon.findMany({
        where,
        skip: parseInt(skip),
        take: parseInt(limit),
        orderBy: { id: 'asc' }
      }),
      prisma.pokemon.count({ where })
    ]);

    res.json({
      pokemons,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Erro ao buscar pokémons:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/pokemons/:id - Buscar pokémon por ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pokemon = await prisma.pokemon.findUnique({
      where: { id: parseInt(id) }
    });

    if (!pokemon) {
      return res.status(404).json({ error: 'Pokémon não encontrado' });
    }

    res.json(pokemon);
  } catch (error) {
    console.error('Erro ao buscar pokémon:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/pokemons/search/:nome - Buscar pokémon por nome
router.get('/search/:nome', async (req, res) => {
  try {
    const { nome } = req.params;
    const pokemons = await prisma.pokemon.findMany({
      where: {
        nome: {
          contains: nome,
          mode: 'insensitive'
        }
      },
      orderBy: { id: 'asc' }
    });

    res.json(pokemons);
  } catch (error) {
    console.error('Erro ao buscar pokémons por nome:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// POST /api/pokemons - Criar novo pokémon
router.post('/', async (req, res) => {
  try {
    const { id, nome, tipo, imagem } = req.body;

    if (!id || !nome || !tipo || !imagem) {
      return res.status(400).json({ 
        error: 'ID, nome, tipo e imagem são obrigatórios' 
      });
    }

    // Verificar se o pokémon já existe
    const pokemonExistente = await prisma.pokemon.findUnique({
      where: { id: parseInt(id) }
    });

    if (pokemonExistente) {
      return res.status(409).json({ error: 'Pokémon com este ID já existe' });
    }

    const novoPokemon = await prisma.pokemon.create({
      data: {
        id: parseInt(id),
        nome,
        tipo,
        imagem
      }
    });

    res.status(201).json({
      message: 'Pokémon criado com sucesso',
      pokemon: novoPokemon
    });
  } catch (error) {
    console.error('Erro ao criar pokémon:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// PUT /api/pokemons/:id - Atualizar pokémon
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, tipo, imagem } = req.body;

    const dadosAtualizacao = {};
    if (nome) dadosAtualizacao.nome = nome;
    if (tipo) dadosAtualizacao.tipo = tipo;
    if (imagem) dadosAtualizacao.imagem = imagem;

    const pokemonAtualizado = await prisma.pokemon.update({
      where: { id: parseInt(id) },
      data: dadosAtualizacao
    });

    res.json({
      message: 'Pokémon atualizado com sucesso',
      pokemon: pokemonAtualizado
    });
  } catch (error) {
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Pokémon não encontrado' });
    }
    console.error('Erro ao atualizar pokémon:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// DELETE /api/pokemons/:id - Deletar pokémon
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.pokemon.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Pokémon deletado com sucesso' });
  } catch (error) {
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Pokémon não encontrado' });
    }
    console.error('Erro ao deletar pokémon:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
