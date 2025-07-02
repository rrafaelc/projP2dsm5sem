-- Script para configurar o banco PostgreSQL para o Pokédx Fatec DSM
-- Execute este script como superusuário (postgres) ou usuário com privilégios

-- 1. Criar o banco de dados
CREATE DATABASE pokedex_fatec;

-- 2. Criar usuário específico para a aplicação (opcional, mas recomendado)
CREATE USER pokedex_user WITH PASSWORD 'pokedex_password_2025';

-- 3. Conceder privilégios ao usuário
GRANT ALL PRIVILEGES ON DATABASE pokedex_fatec TO pokedex_user;

-- 4. Conectar ao banco recém-criado
\c pokedex_fatec;

-- 5. Conceder privilégios no schema public
GRANT ALL ON SCHEMA public TO pokedex_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pokedex_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pokedex_user;

-- 6. Definir privilégios padrão para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO pokedex_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO pokedex_user;

-- Informações de conexão após a configuração:
-- Host: localhost
-- Porta: 5432 (padrão)
-- Banco: pokedex_fatec
-- Usuário: pokedex_user
-- Senha: pokedex_password_2025

-- String de conexão completa:
-- postgresql://pokedex_user:pokedex_password_2025@localhost:5432/pokedex_fatec?schema=public
