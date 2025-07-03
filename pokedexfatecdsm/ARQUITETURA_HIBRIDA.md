# 🏗️ Arquitetura Híbrida - Pokédex Fatec DSM

## 📱 Funcionamento Offline + Online

Esta aplicação agora usa uma **arquitetura híbrida** que combina:
- **API Node.js** (para login e sincronização)
- **SQLite local** (para dados offline)

## 🔄 Como Funciona

### 🔐 **Login**
1. **Primeira tentativa:** API Node.js (online)
2. **Se offline:** SQLite local (cache)
3. **Após login online:** Dados salvos localmente

### 📦 **Dados dos Pokémons**
- **Sempre SQLite local** (funcionamento offline)
- **Sincronização automática** quando API disponível
- **Primeiro acesso:** Baixa da API e salva localmente

### 🌐 **Estados da Aplicação**

#### **Modo Online (API + SQLite)**
```
Login → API ✅ → SQLite (cache) → Sincronizar Pokémons
```

#### **Modo Offline (SQLite apenas)**
```
Login → SQLite (cache) ✅ → Pokémons do SQLite
```

## 🚀 **Fluxo de Uso**

### **Primeira vez (Online)**
1. Usuário faz login → **API valida** → Credenciais salvas no SQLite
2. Pokémons baixados da **API** → Salvos no **SQLite**
3. App funcionando **totalmente offline**

### **Usos subsequentes (Offline)**
1. Usuário faz login → **SQLite valida** (sem internet)
2. Pokémons carregados do **SQLite** (instantâneo)
3. Quando voltar online → **Sincronização automática**

## 📊 **Estrutura do Banco SQLite**

### **Tabela: usuarios**
```sql
CREATE TABLE usuarios (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE,
  senha TEXT,
  token TEXT,
  synced_at TEXT
);
```

### **Tabela: pokemons**
```sql
CREATE TABLE pokemons (
  id INTEGER PRIMARY KEY,
  nome TEXT,
  tipo TEXT,
  imagem TEXT,
  synced_at TEXT
);
```

## 🔧 **Métodos Principais**

### **`getUser(email, senha)`**
```dart
// 1. Tenta API (online)
// 2. Se falhar, usa SQLite (offline)
// 3. Salva no cache se login via API
```

### **`getPokemons()`**
```dart
// 1. Busca no SQLite local
// 2. Se vazio, sincroniza da API
// 3. Sempre retorna dados locais
```

### **`sincronizarPokemons()`**
```dart
// 1. Verifica se API está disponível
// 2. Baixa dados da API
// 3. Atualiza SQLite local
```

## 🎯 **Vantagens da Arquitetura**

### ✅ **Para o Professor**
- **Offline first:** App funciona sem internet
- **SQLite:** Dados locais como solicitado
- **Sincronização:** Dados sempre atualizados quando online

### ✅ **Para o Usuário**
- **Performance:** Dados instantâneos (SQLite)
- **Confiabilidade:** Funciona sem internet
- **Atualização:** Sincroniza automaticamente

### ✅ **Para o Desenvolvedor**
- **Flexibilidade:** API para novos recursos
- **Cache inteligente:** SQLite para performance
- **Fallback:** Nunca deixa o usuário na mão

## 🧪 **Como Testar**

### **Teste Online**
1. API rodando (`npm run dev`)
2. Login → Deve funcionar via API
3. Pokémons → Sincronizados e salvos localmente

### **Teste Offline**
1. Pare a API (`Ctrl+C`)
2. Login → Deve funcionar via SQLite
3. Pokémons → Carregados do SQLite local

### **Teste de Sincronização**
1. Online: Adicione pokémon via API
2. Offline: Veja se aparece no app (após sincronização)
3. Volte online: Sincronização automática

## 📱 **Interface de Teste**

Use o botão **"🧪 Testar Híbrido"** na tela de login para:
- Verificar conectividade
- Testar login híbrido
- Ver dados do SQLite
- Monitorar sincronização

## 🔍 **Logs e Debug**

O app mostra logs detalhados:
```
🔐 Tentando login via API com: fatec@pokemon.com
📊 Status Code: 200
✅ Login realizado com sucesso!
💾 Usuário salvo no cache local
🔄 Iniciando sincronização de pokémons...
✅ 10 pokémons sincronizados!
```

## 🎉 **Resultado Final**

Uma aplicação que:
- ✅ **Funciona offline** (SQLite)
- ✅ **Sincroniza online** (API)
- ✅ **Cache inteligente** (híbrido)
- ✅ **Performance máxima** (local-first)
- ✅ **Confiabilidade total** (fallback)

**Perfeita para as necessidades acadêmicas e práticas! 🎓**
