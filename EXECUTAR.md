# 🚀 Como Executar o Bet Analytics

## ⚡ Execução Rápida

### 1. Pré-requisitos

- Docker e Docker Compose instalados
- Python 3.11+ (opcional, para desenvolvimento)

### 2. Variáveis de Ambiente

```bash
# Criar arquivo .env na raiz do projeto
DATABASE_URL=postgresql://bet_user:bet_password@localhost:5432/bet_db
REDIS_URL=redis://localhost:6379
SECRET_KEY=minha_chave_secreta_super_segura
DEBUG=true
ENVIRONMENT=development

# API Keys (opcionais por enquanto)
FOOTBALL_API_KEY=sua_chave_aqui
RAPID_API_KEY=sua_chave_aqui
```

### 3. Executar com Docker

```bash
# Iniciar todos os serviços
docker-compose up -d

# Verificar se os serviços estão funcionando
docker-compose ps

# Ver logs se houver problema
docker-compose logs backend
```

### 4. Popular com Dados de Exemplo

```bash
# Aguardar alguns segundos para o banco inicializar
python scripts/seed_data.py
```

### 5. Testar a API

```bash
# Verificar saúde da API
curl http://localhost:8000/health

# Listar times
curl http://localhost:8000/api/v1/teams

# Buscar partidas
curl http://localhost:8000/api/v1/matches
```

## 🌐 Acessos

- **API**: http://localhost:8000
- **Documentação**: http://localhost:8000/api/v1/docs
- **ReDoc**: http://localhost:8000/api/v1/redoc

## 🔧 Desenvolvimento Local

### Backend apenas

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Banco de dados local

```bash
# Se preferir PostgreSQL local
createdb bet_db
psql bet_db -c "CREATE USER bet_user WITH PASSWORD 'bet_password';"
psql bet_db -c "GRANT ALL PRIVILEGES ON DATABASE bet_db TO bet_user;"
```

## 🛠️ Comandos Úteis

```bash
# Parar serviços
docker-compose down

# Reconstruir containers
docker-compose build

# Ver logs em tempo real
docker-compose logs -f

# Limpar volumes (CUIDADO: apaga dados)
docker-compose down -v

# Executar shell no container
docker-compose exec backend bash

# Testar Celery
docker-compose exec worker celery -A app.worker inspect active

# Executar tarefa de teste
docker-compose exec backend python -c "from app.tasks import test_task; print(test_task.delay())"
```

## 📊 Endpoints Principais

### Times

- `GET /api/v1/teams` - Listar times
- `POST /api/v1/teams` - Criar time
- `GET /api/v1/teams/1` - Buscar time específico

### Partidas

- `GET /api/v1/matches` - Listar partidas
- `GET /api/v1/matches/today` - Partidas de hoje
- `POST /api/v1/matches` - Criar partida

### Análises

- `GET /api/v1/analysis/match/1` - Analisar partida
- `GET /api/v1/analysis/trends` - Buscar trends
- `GET /api/v1/analysis/team/1/form` - Forma do time

## 🐛 Solução de Problemas

### Erro de porta em uso

```bash
# Verificar qual processo está usando a porta
lsof -i :8000
netstat -tlnp | grep 8000

# Parar serviços conflitantes
docker-compose down
```

### Erro de permissão

```bash
# Dar permissão aos scripts
chmod +x scripts/*.py
```

### Erro de banco de dados

```bash
# Verificar logs do PostgreSQL
docker-compose logs db

# Recriar banco (apaga dados)
docker-compose down -v
docker-compose up -d db
```

### Erro de dependências

```bash
# Reconstruir imagem
docker-compose build backend --no-cache
```

## 🎯 Próximos Passos

1. **Testar endpoints** na documentação interativa
2. **Criar times e partidas** via API
3. **Verificar análises** funcionando
4. **Implementar Fase 2** - Coleta de dados

## 📞 Suporte

- Verifique os logs: `docker-compose logs`
- Consulte a documentação: `docs/SETUP.md`
- Teste os endpoints: http://localhost:8000/api/v1/docs

---

**Status**: ✅ Pronto para executar  
**Tempo de setup**: ~5 minutos  
**Documentação**: Completa
