# API Pokédex Fatec DSM

API Node.js com Express e PostgreSQL para o projeto Pokédex da Fatec DSM.

## 📋 Pré-requisitos

- Node.js 16+ 
- PostgreSQL 12+
- npm ou yarn

## 🚀 Instalação

1. **Instalar dependências:**
```bash
npm install
```

2. **Configurar banco de dados:**
   - Criar um banco PostgreSQL chamado `pokedex_fatec`
   - Configurar as credenciais no arquivo `.env`

3. **Configurar Prisma:**
```bash
npm run prisma:generate
npm run prisma:push
```

4. **Popular banco com dados iniciais:**
```bash
npm run seed
```

## 🏃‍♂️ Executando

### Desenvolvimento
```bash
npm run dev
```

### Produção
```bash
npm start
```

A API estará disponível em `http://localhost:3000`

## 📚 Endpoints

### 🏠 Geral
- `GET /` - Informações da API
- `GET /health` - Health check

### 👥 Usuários
- `GET /api/usuarios` - Listar usuários
- `GET /api/usuarios/:id` - Buscar usuário por ID
- `POST /api/usuarios` - Criar usuário
- `POST /api/usuarios/login` - Autenticar usuário
- `PUT /api/usuarios/:id` - Atualizar usuário
- `DELETE /api/usuarios/:id` - Deletar usuário

### 🐾 Pokémons
- `GET /api/pokemons` - Listar pokémons (com paginação)
- `GET /api/pokemons/:id` - Buscar pokémon por ID
- `GET /api/pokemons/search/:nome` - Buscar por nome
- `POST /api/pokemons` - Criar pokémon
- `PUT /api/pokemons/:id` - Atualizar pokémon
- `DELETE /api/pokemons/:id` - Deletar pokémon

### 🔄 Sincronização
- `POST /api/sync/pokemon` - Sincronizar pokémon (compatível com PHP)
- `POST /api/sync/user` - Sincronizar usuário (compatível com PHP)
- `POST /api/sync/bulk` - Sincronização em lote

## 🔧 Configuração

### Variáveis de Ambiente (.env)
```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://usuario:senha@localhost:5432/pokedex_fatec?schema=public"
JWT_SECRET=sua_chave_secreta_jwt
```

### Banco de Dados PostgreSQL

1. **Criar banco:**
```sql
CREATE DATABASE pokedex_fatec;
```

2. **Configurar usuário (opcional):**
```sql
CREATE USER pokedex_user WITH PASSWORD 'sua_senha';
GRANT ALL PRIVILEGES ON DATABASE pokedex_fatec TO pokedex_user;
```

## 📦 Scripts Disponíveis

- `npm start` - Executar em produção
- `npm run dev` - Executar em desenvolvimento (com nodemon)
- `npm run seed` - Popular banco com dados iniciais
- `npm run prisma:generate` - Gerar cliente Prisma
- `npm run prisma:push` - Aplicar schema ao banco
- `npm run prisma:studio` - Abrir Prisma Studio

## 🌟 Funcionalidades

- ✅ CRUD completo para usuários e pokémons
- ✅ Autenticação JWT
- ✅ Hash de senhas com bcrypt
- ✅ Paginação e filtros
- ✅ Busca por nome
- ✅ Compatibilidade com API PHP existente
- ✅ Sincronização em lote
- ✅ Validação de dados
- ✅ Tratamento de erros
- ✅ CORS habilitado

## 🔗 Integração com Flutter

Para integrar com o app Flutter, atualize as URLs no `database_helper.dart`:

```dart
// Trocar de:
Uri.parse('https://url-do-servidor.com/api/sync_pokemon.php')

// Para:
Uri.parse('http://localhost:3000/api/sync/pokemon')
```

## 🛠️ Tecnologias

- **Node.js** - Runtime JavaScript
- **Express** - Framework web
- **Prisma** - ORM para PostgreSQL
- **PostgreSQL** - Banco de dados
- **JWT** - Autenticação
- **bcryptjs** - Hash de senhas
- **CORS** - Cross-origin requests

## 📝 Dados Iniciais

O comando `npm run seed` cria:

**Usuário padrão:**
- Email: `fatec@pokemon.com`
- Senha: `pikachu`

**Pokémons iniciais:**
- Bulbasaur, Ivysaur, Venusaur
- Charmander, Charmeleon, Charizard  
- Squirtle, Wartortle, Blastoise
- Caterpie
