#!/bin/bash

echo "🚀 Configurando API Pokédex Fatec DSM..."

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale o Node.js 16+"
    exit 1
fi

# Verificar se PostgreSQL está instalado
if ! command -v psql &> /dev/null; then
    echo "⚠️ PostgreSQL não encontrado. Certifique-se de que está instalado e rodando"
fi

echo "📦 Instalando dependências..."
npm install

echo "🗄️ Configurando banco de dados..."
npm run prisma:generate
npm run prisma:push

echo "🌱 Populando banco com dados iniciais..."
npm run seed

echo "✅ Configuração concluída!"
echo ""
echo "🏃‍♂️ Para executar a API:"
echo "   npm run dev    (desenvolvimento)"
echo "   npm start      (produção)"
echo ""
echo "🌐 A API estará disponível em: http://localhost:3000"
