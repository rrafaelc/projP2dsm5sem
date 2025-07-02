const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../config/database');

const router = express.Router();

// GET /api/usuarios - Listar todos os usuários
router.get('/', async (req, res) => {
  try {
    const usuarios = await prisma.usuario.findMany({
      select: {
        id: true,
        email: true,
        createdAt: true,
        updatedAt: true
      }
    });
    res.json(usuarios);
  } catch (error) {
    console.error('Erro ao buscar usuários:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/usuarios/:id - Buscar usuário por ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const usuario = await prisma.usuario.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        email: true,
        createdAt: true,
        updatedAt: true
      }
    });

    if (!usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    res.json(usuario);
  } catch (error) {
    console.error('Erro ao buscar usuário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// POST /api/usuarios/login - Autenticar usuário
router.post('/login', async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    const usuario = await prisma.usuario.findUnique({
      where: { email }
    });

    if (!usuario) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Verificar senha (se for hash) ou comparar diretamente para compatibilidade
    let senhaValida = false;
    if (senha === usuario.senha) {
      senhaValida = true; // Para compatibilidade com senhas em texto plano
    } else {
      try {
        senhaValida = await bcrypt.compare(senha, usuario.senha);
      } catch (bcryptError) {
        senhaValida = false;
      }
    }

    if (!senhaValida) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Gerar token JWT
    const token = jwt.sign(
      { userId: usuario.id, email: usuario.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login realizado com sucesso',
      user: {
        id: usuario.id,
        email: usuario.email
      },
      token
    });
  } catch (error) {
    console.error('Erro ao fazer login:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// POST /api/usuarios - Criar novo usuário
router.post('/', async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    // Verificar se o usuário já existe
    const usuarioExistente = await prisma.usuario.findUnique({
      where: { email }
    });

    if (usuarioExistente) {
      return res.status(409).json({ error: 'Email já está em uso' });
    }

    // Hash da senha
    const senhaHash = await bcrypt.hash(senha, 10);

    const novoUsuario = await prisma.usuario.create({
      data: {
        email,
        senha: senhaHash
      },
      select: {
        id: true,
        email: true,
        createdAt: true
      }
    });

    res.status(201).json({
      message: 'Usuário criado com sucesso',
      user: novoUsuario
    });
  } catch (error) {
    console.error('Erro ao criar usuário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// PUT /api/usuarios/:id - Atualizar usuário
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { email, senha } = req.body;

    const dadosAtualizacao = {};
    if (email) dadosAtualizacao.email = email;
    if (senha) dadosAtualizacao.senha = await bcrypt.hash(senha, 10);

    const usuarioAtualizado = await prisma.usuario.update({
      where: { id: parseInt(id) },
      data: dadosAtualizacao,
      select: {
        id: true,
        email: true,
        updatedAt: true
      }
    });

    res.json({
      message: 'Usuário atualizado com sucesso',
      user: usuarioAtualizado
    });
  } catch (error) {
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    console.error('Erro ao atualizar usuário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// DELETE /api/usuarios/:id - Deletar usuário
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.usuario.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Usuário deletado com sucesso' });
  } catch (error) {
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    console.error('Erro ao deletar usuário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
