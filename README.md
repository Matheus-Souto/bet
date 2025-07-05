# ⚽ Bet Analytics - Sistema de Análise de Futebol

Sistema inteligente que analisa jogos de futebol usando estatísticas para identificar trends e oportunidades de apostas.

## 🎯 Objetivos

- Coletar dados estatísticos de jogos e times
- Analisar padrões e tendências
- Gerar insights para apostas esportivas
- Fornecer dashboard interativo com visualizações

## 🏗️ Estrutura do Projeto

```
bet/
├── backend/           # API e lógica de negócio
├── frontend/          # Interface do usuário
├── data/             # Dados brutos e processados
├── scripts/          # Scripts de automação
├── docs/             # Documentação
└── docker/           # Configurações Docker
```

## 🚀 Tecnologias

- **Backend**: Python, FastAPI, PostgreSQL, Redis
- **Frontend**: React, TypeScript, Chart.js
- **Data**: Pandas, NumPy, Scikit-learn
- **Infraestrutura**: Docker, Docker Compose

## 📋 Fases de Desenvolvimento

- [x] **Fase 1**: Fundação e estrutura básica
- [ ] **Fase 2**: Coleta de dados
- [ ] **Fase 3**: Análise estatística
- [ ] **Fase 4**: Interface do usuário
- [ ] **Fase 5**: Machine Learning
- [ ] **Fase 6**: Refinamento

## 🔧 Configurações de Desenvolvimento

O projeto suporta **3 modos de execução**:

### 1. 🐳 Docker Completo (Mais Simples)

```bash
docker-compose up -d
```

- **Prós**: Setup instantâneo, isolamento completo
- **Contras**: Debug limitado, hot reload mais lento

### 2. ⚡ Híbrido: Local + VM (Recomendado para Dev)

```bash
# VM: Infraestrutura
docker-compose -f docker-compose.infrastructure.yml up -d

# Windows: Backend local
scripts\setup_windows.bat
run_backend.bat
```

- **Prós**: Debug completo, hot reload instantâneo, IDE nativo
- **Contras**: Setup inicial mais complexo

### 3. 🏠 Local Completo

```bash
# Instalar PostgreSQL, Redis localmente
pip install -r backend/requirements.txt
uvicorn app.main:app --reload
```

- **Prós**: Performance máxima
- **Contras**: Configuração manual dos serviços

## ⚡ Execução Rápida

### Docker Completo

1. `docker-compose up -d`
2. `python scripts/seed_data.py`
3. Acesse: http://localhost:8000/api/v1/docs

### Desenvolvimento Híbrido (Recomendado)

1. **Na VM**: `docker-compose -f docker-compose.infrastructure.yml up -d`
2. **No Windows**: `scripts\setup_windows.bat`
3. **Configurar .env**: IP da VM em `backend\.env`
4. **Executar**: `run_backend.bat`

## 🌐 Acessos

- **API**: http://localhost:8000
- **Documentação**: http://localhost:8000/api/v1/docs
- **PgAdmin**: http://VM_IP:8080 (admin@bet.com / admin123)
- **Redis Commander**: http://VM_IP:8081

## 📚 Documentação

- [**Setup Rápido**](EXECUTAR.md) - Execução imediata
- [**Desenvolvimento Híbrido**](EXECUTAR_DEV_LOCAL.md) - Local + VM
- [**Setup Completo**](docs/SETUP.md) - Configuração detalhada
- [**API Documentation**](docs/API.md) - Endpoints e exemplos
- [**Guia de Desenvolvimento**](docs/SETUP_DEV_LOCAL.md) - Dev local + VM

## 🛠️ Scripts Úteis

### Windows (Desenvolvimento Local)

- `setup_windows.bat` - Configuração inicial
- `run_backend.bat` - Executar backend
- `test_connection.bat` - Testar conexão com VM
- `seed_database.bat` - Popular banco de dados

### VM/Linux (Infraestrutura)

- `scripts/setup_vm.sh` - Configurar VM automaticamente
- `check_services.sh` - Verificar status dos serviços

## 🎯 Funcionalidades Implementadas

### 📊 API REST Completa

- **Times**: CRUD completo com estatísticas
- **Partidas**: Gestão de jogos com odds
- **Análises**: Predições e trends automáticos
- **Filtros**: Por liga, país, data, status

### 🗄️ Banco de Dados

- **PostgreSQL** com modelos relacionais
- **Estatísticas detalhadas** de times e partidas
- **Odds e predições** para análises
- **Dados de exemplo** inclusos

### ⚡ Infraestrutura

- **FastAPI** com documentação automática
- **Celery** para tarefas assíncronas
- **Redis** para cache e filas
- **Docker** para containerização

## 📈 Exemplos de API

```bash
# Listar times
curl http://localhost:8000/api/v1/teams

# Partidas de hoje
curl http://localhost:8000/api/v1/matches/today

# Analisar partida
curl http://localhost:8000/api/v1/analysis/match/1

# Buscar trends
curl http://localhost:8000/api/v1/analysis/trends
```

## ⚠️ Disclaimer

Este sistema é apenas para fins educacionais e de análise. Não garantimos resultados nas apostas.
Aposte com responsabilidade e dentro de suas possibilidades.

## 🎯 Próximos Passos

### Fase 2 - Coleta de Dados

- [ ] Integração com Football-Data API
- [ ] Sistema de web scraping
- [ ] Pipeline ETL automatizado
- [ ] Validação de dados em tempo real

### Futuras Funcionalidades

- [ ] Dashboard React interativo
- [ ] Algoritmos de Machine Learning
- [ ] Análise em tempo real
- [ ] Sistema de notificações
- [ ] Mobile app

## 📞 Suporte

- **Documentação**: Consulte os arquivos em `docs/`
- **API Docs**: http://localhost:8000/api/v1/docs
- **Troubleshooting**: Verifique logs com `docker-compose logs`

---

**Status**: ✅ **FASE 1 COMPLETA** + **CONFIGURAÇÃO HÍBRIDA**  
**Próxima etapa**: Fase 2 - Coleta de Dados  
**Modos de execução**: 3 opções disponíveis  
**Pronto para**: Desenvolvimento profissional 🚀

## 📧 Contato

Para dúvidas ou sugestões sobre o projeto.
