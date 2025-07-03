# 🧪 Guia de Teste Completo - Pokédex Híbrida

## 📋 Visão Geral

Esta aplicação demonstra uma **arquitetura híbrida** Flutter + Node.js/Express/PostgreSQL + SQLite, atendendo aos requisitos do professor:

- ✅ **Login via API** (Node.js/Express/PostgreSQL)
- ✅ **Funcionamento offline** usando SQLite local
- ✅ **Cache do usuário** para login offline após primeiro login online
- ✅ **Pokémons sempre via SQLite** (dados offline)
- ✅ **Sincronização automática** API → SQLite quando online

## 🚀 Como Testar

### 1. Preparação do Ambiente

#### Backend (Node.js API):
```bash
cd nodejsAPI
npm install
npm run dev
```

#### Frontend (Flutter):
```bash
flutter pub get
flutter run
```

### 2. Cenários de Teste

#### 🌐 **Teste 1: Modo Online (Primeira vez)**
1. API rodando (`npm run dev`)
2. Abrir app Flutter
3. Fazer login com:
   - **Email:** `fatec@pokemon.com`
   - **Senha:** `pikachu`
4. **Resultado esperado:**
   - Login via API bem-sucedido
   - Usuário salvo no cache SQLite
   - Pokémons sincronizados da API para SQLite
   - Lista de pokémons exibida

#### 📱 **Teste 2: Modo Offline (Após primeiro login)**
1. **Parar a API** (Ctrl+C no terminal da API)
2. **Reiniciar o app** Flutter
3. Fazer login com as mesmas credenciais
4. **Resultado esperado:**
   - Login via cache SQLite (offline)
   - Pokémons carregados do SQLite local
   - App funciona normalmente sem API

#### 🔄 **Teste 3: Sincronização Automática**
1. **Reiniciar a API** (`npm run dev`)
2. No app, usar o botão "🧪 Testar API"
3. **Resultado esperado:**
   - Detecta API online
   - Realiza login via API
   - Sincroniza pokémons automaticamente
   - Exibe status da sincronização

### 3. Tela de Teste Integrada

O app possui uma **tela de teste dedicada** acessível via botão "🧪 Testar API" na tela de login.

Esta tela testa:
- ✅ Conectividade com a API
- ✅ Login híbrido (API + cache)
- ✅ Busca de pokémons (SQLite)
- ✅ Sincronização automática

### 4. Verificações Detalhadas

#### 🔍 **Logs do Console**
O app gera logs detalhados no console Flutter:
- `🔐 Tentando login via API...`
- `✅ Login realizado com sucesso!`
- `💾 Usuário salvo no cache local`
- `🔄 Iniciando sincronização...`
- `✅ X pokémons sincronizados!`
- `⚠️ API indisponível - modo offline`

#### 📊 **Estrutura do Banco SQLite**
```sql
-- Tabela para cache do usuário
usuarios (id, email, senha, token, synced_at)

-- Tabela para pokémons offline
pokemons (id, nome, tipo, imagem, synced_at)
```

## 🎯 Fluxo de Funcionamento

### Login Online:
```
App → API (Node.js) → PostgreSQL → Retorna token → Salva no SQLite
```

### Login Offline:
```
App → SQLite local → Verifica credenciais → Login bem-sucedido
```

### Pokémons:
```
App → SEMPRE SQLite local → Exibe dados
Background: API → SQLite (sincronização quando online)
```

## 📱 Telas da Aplicação

1. **Tela de Login** (`tela_login.dart`)
   - Login híbrido (API + offline)
   - Botão de teste da API
   - Credenciais pré-preenchidas

2. **Tela Home** (`tela_home.dart`)
   - Lista de pokémons do SQLite
   - Imagens dos assets locais
   - Funciona 100% offline

3. **Tela de Teste** (`test_api_screen.dart`)
   - Diagnóstico completo
   - Status online/offline
   - Logs detalhados

## 🔧 Arquivos Principais

### Flutter:
- `lib/database_helper.dart` - **Core híbrido**
- `lib/tela_login.dart` - Login
- `lib/tela_home.dart` - Lista pokémons
- `lib/test_api_screen.dart` - Testes

### Node.js API:
- `nodejsAPI/src/server.js` - Servidor Express
- `nodejsAPI/src/routes/` - Endpoints REST
- `nodejsAPI/src/seed.js` - Dados iniciais

### Configuração:
- `pubspec.yaml` - Dependências Flutter
- `android/app/src/main/AndroidManifest.xml` - Permissões rede
- `nodejsAPI/package.json` - Dependências Node.js

## ✅ Validação para o Professor

### Requisitos Atendidos:
1. ✅ **SQLite para funcionamento offline** - ✅
2. ✅ **API para login** - ✅
3. ✅ **Cache de usuário** - ✅
4. ✅ **Sincronização de dados** - ✅
5. ✅ **Imagens dos pokémons** - ✅
6. ✅ **CRUD completo** - ✅

### Como Demonstrar:
1. **Mostrar funcionamento online** (API rodando)
2. **Parar API e mostrar funcionamento offline**
3. **Reiniciar API e mostrar sincronização**
4. **Usar tela de teste para diagnóstico completo**

## 🐛 Solução de Problemas

### API não conecta:
```bash
# Verificar se está rodando
curl http://localhost:3000/health

# Ou acessar no navegador
http://localhost:3000
```

### Flutter não roda:
```bash
flutter clean
flutter pub get
flutter run
```

### Banco PostgreSQL:
```bash
# No nodejsAPI
npm run seed  # Recria dados iniciais
```

## 📝 Credenciais de Teste

- **Email:** `fatec@pokemon.com`
- **Senha:** `pikachu`

## 🎉 Demonstração Completa

Para uma demonstração completa ao professor:

1. **Inicie a API:** `cd nodejsAPI && npm run dev`
2. **Inicie o Flutter:** `flutter run`
3. **Teste online:** Login → Ver pokémons
4. **Pare a API:** Ctrl+C no terminal
5. **Teste offline:** Reinicie app → Login funciona
6. **Reinicie API:** `npm run dev`
7. **Use tela de teste:** Botão "🧪 Testar API"

✅ **O app demonstra perfeitamente a arquitetura híbrida solicitada!**
