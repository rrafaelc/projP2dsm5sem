@echo off

echo 🚀 Configurando API Pokédx Fatec DSM...

REM Verificar se Node.js está instalado
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js não encontrado. Por favor, instale o Node.js 16+
    pause
    exit /b 1
)

REM Verificar se PostgreSQL está instalado
psql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ PostgreSQL não encontrado. Certifique-se de que está instalado e rodando
)

echo 📦 Instalando dependências...
npm install

echo 🗄️ Configurando banco de dados...
npm run prisma:generate
npm run prisma:push

echo 🌱 Populando banco com dados iniciais...
npm run seed

echo ✅ Configuração concluída!
echo.
echo 🏃‍♂️ Para executar a API:
echo    npm run dev    (desenvolvimento)
echo    npm start      (produção)
echo.
echo 🌐 A API estará disponível em: http://localhost:3000
pause
