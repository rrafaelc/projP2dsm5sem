# 🚀 Guia de Instalação Completo - API Pokédx Fatec DSM

## 📋 Pré-requisitos

### 1. Node.js
- Versão 16 ou superior
- Download: https://nodejs.org/

### 2. PostgreSQL
- Versão 12 ou superior
- Download: https://www.postgresql.org/download/

### 3. Git (opcional)
- Para clonar o repositório
- Download: https://git-scm.com/

## 🛠️ Instalação do PostgreSQL

### Windows
1. Baixe o instalador do PostgreSQL
2. Execute e siga o assistente
3. **Importante**: Anote a senha do usuário `postgres`
4. Mantenha a porta padrão `5432`

### Durante a instalação
- Usuário: `postgres`
- Senha: [defina uma senha forte]
- Porta: `5432`
- Locale: `Portuguese, Brazil` ou `Default locale`

## 🗄️ Configuração do Banco de Dados

### Método 1: Usando pgAdmin (Interface Gráfica)
1. Abra o pgAdmin
2. Conecte ao servidor PostgreSQL
3. Clique com botão direito em "Databases" → "Create" → "Database"
4. Nome: `pokedex_fatec`
5. Clique em "Save"

### Método 2: Usando SQL (Linha de Comando)
1. Abra o terminal/prompt
2. Execute:
```bash
psql -U postgres
```
3. Digite a senha quando solicitado
4. Execute o comando:
```sql
CREATE DATABASE pokedex_fatec;
\q
```

### Método 3: Executar script SQL
1. Execute o arquivo `setup-database.sql`:
```bash
psql -U postgres -f setup-database.sql
```

## 🔧 Configuração da API

### 1. Instalar dependências
```bash
cd nodejsAPI
npm install
```

### 2. Configurar variáveis de ambiente
1. Copie o arquivo `.env.example` para `.env`:
```bash
copy .env.example .env
```

2. Edite o arquivo `.env` com suas credenciais:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://postgres:SUA_SENHA@localhost:5432/pokedex_fatec?schema=public"
JWT_SECRET=pokedex_fatec_secret_key_2025
```

**Substitua `SUA_SENHA` pela senha do PostgreSQL!**

### 3. Configurar Prisma
```bash
npm run prisma:generate
npm run prisma:push
```

### 4. Popular banco com dados iniciais
```bash
npm run seed
```

## 🏃‍♂️ Executando a API

### Desenvolvimento (com auto-reload)
```bash
npm run dev
```

### Produção
```bash
npm start
```

A API estará disponível em: `http://localhost:3000`

## ✅ Testando a Instalação

### 1. Verificar se a API está funcionando
Abra no navegador: `http://localhost:3000/health`

Deve retornar:
```json
{
  "status": "ok",
  "message": "Pokédx API is running!",
  "timestamp": "2025-07-02T..."
}
```

### 2. Executar testes automatizados
```bash
npm test
```

### 3. Testar login
- Email: `fatec@pokemon.com`
- Senha: `pikachu`

## 🌐 Endpoints Disponíveis

### Informações
- `GET /` - Informações da API
- `GET /health` - Status da API

### Usuários
- `POST /api/usuarios/login` - Login
- `GET /api/usuarios` - Listar usuários
- `POST /api/usuarios` - Criar usuário

### Pokémons
- `GET /api/pokemons` - Listar pokémons
- `GET /api/pokemons/:id` - Buscar por ID
- `GET /api/pokemons/search/:nome` - Buscar por nome
- `POST /api/pokemons` - Criar pokémon

### Sincronização
- `POST /api/sync/pokemon` - Sincronizar pokémon
- `POST /api/sync/user` - Sincronizar usuário

## 🔧 Comandos Úteis

```bash
# Instalar dependências
npm install

# Executar em desenvolvimento
npm run dev

# Executar em produção
npm start

# Popular banco de dados
npm run seed

# Gerar cliente Prisma
npm run prisma:generate

# Aplicar schema ao banco
npm run prisma:push

# Abrir Prisma Studio (interface visual do banco)
npm run prisma:studio

# Executar testes
npm test
```

## 🎯 Integração com Flutter

No arquivo `lib/database_helper.dart`, a URL da API já está configurada para:
```dart
static const String _baseUrl = 'http://localhost:3000/api';
```

Para produção, altere para o endereço do seu servidor.

## ❓ Problemas Comuns

### Erro de conexão com PostgreSQL
- Verifique se o PostgreSQL está rodando
- Confirme a senha no arquivo `.env`
- Teste a conexão: `psql -U postgres -d pokedex_fatec`

### Porta 3000 em uso
- Altere a porta no arquivo `.env`: `PORT=3001`
- Ou feche outros aplicativos na porta 3000

### Erro "prisma generate"
- Execute: `npm run prisma:generate`
- Se persistir: `rm -rf node_modules && npm install`

### Banco não existe
- Execute o script: `psql -U postgres -f setup-database.sql`
- Ou crie manualmente: `CREATE DATABASE pokedex_fatec;`

## 📞 Suporte

Se encontrar problemas:
1. Verifique se seguiu todos os passos
2. Consulte os logs da API
3. Teste a conexão com o banco separadamente
4. Verifique se as portas estão livres

## 🎉 Pronto!

Sua API Pokédx está funcionando! 

- API: http://localhost:3000
- Health: http://localhost:3000/health
- Login: `fatec@pokemon.com` / `pikachu`
