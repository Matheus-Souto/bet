# 🔧 Configuração Inicial - Bet Analytics

## Pré-requisitos

- Python 3.11+
- Docker e Docker Compose
- Node.js 18+ (para frontend)
- PostgreSQL 15+
- Redis 7+

## Configuração Rápida com Docker

1. **Clone o repositório**

```bash
git clone <url-do-repositório>
cd bet
```

2. **Copie o arquivo de ambiente**

```bash
cp .env.example .env
```

3. **Configure as variáveis de ambiente**
   Edite o arquivo `.env` com suas configurações:

```env
# Database
DATABASE_URL=postgresql://bet_user:bet_password@localhost:5432/bet_db

# Redis
REDIS_URL=redis://localhost:6379

# API Keys (obtenha gratuitamente)
FOOTBALL_API_KEY=sua_chave_da_football_data_api
RAPID_API_KEY=sua_chave_da_rapid_api

# Security
SECRET_KEY=sua_chave_secreta_super_segura
```

4. **Inicie os serviços**

```bash
docker-compose up -d
```

5. **Acesse a aplicação**

- Backend API: http://localhost:8000
- Documentação API: http://localhost:8000/api/v1/docs
- Frontend: http://localhost:3000

## Configuração Manual (Desenvolvimento)

### Backend

1. **Instale as dependências**

```bash
cd backend
pip install -r requirements.txt
```

2. **Configure o banco de dados**

```bash
# Criar banco PostgreSQL
createdb bet_db

# Executar migrações
alembic upgrade head
```

3. **Inicie o servidor**

```bash
uvicorn app.main:app --reload
```

### Frontend

1. **Instale as dependências**

```bash
cd frontend
npm install
```

2. **Inicie o servidor de desenvolvimento**

```bash
npm start
```

## Obtendo Chaves de API

### Football-Data.org

1. Acesse: https://www.football-data.org/
2. Registre-se gratuitamente
3. Obtenha sua API key (500 requests/mês grátis)

### RapidAPI (API-Football)

1. Acesse: https://rapidapi.com/api-sports/api/api-football
2. Crie uma conta
3. Obtenha sua API key

## Testando a Configuração

```bash
# Testar API
curl http://localhost:8000/health

# Testar conexão com banco
curl http://localhost:8000/api/v1/teams

# Testar Celery
docker-compose exec worker celery -A app.worker inspect active
```

## Problemas Comuns

### Erro de Conexão com Banco

```bash
# Verificar se PostgreSQL está rodando
docker-compose ps

# Verificar logs
docker-compose logs db
```

### Erro de Permissões

```bash
# Dar permissões aos scripts
chmod +x scripts/*.sh
```

### Erro de Dependências

```bash
# Reinstalar dependências
pip install -r requirements.txt --force-reinstall
```

## Próximos Passos

Após a configuração inicial, você pode:

1. **Adicionar dados de exemplo**

```bash
python scripts/seed_data.py
```

2. **Executar testes**

```bash
pytest backend/tests/
```

3. **Monitorar tarefas**

```bash
docker-compose logs -f worker
```

4. **Configurar coleta de dados**
   Edite `backend/app/services/data_collector.py` com suas fontes de dados.

## Suporte

Para dúvidas sobre configuração, consulte:

- [Documentação da API](API.md)
- [Guia de Desenvolvimento](DEVELOPMENT.md)
- [FAQ](FAQ.md)
