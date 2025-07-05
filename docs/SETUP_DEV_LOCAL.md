# 🔧 Setup Desenvolvimento Local + VM

Esta configuração permite rodar a infraestrutura (PostgreSQL, Redis) em uma VM via Docker, enquanto o backend Python roda localmente na sua máquina Windows.

## 🎯 Arquitetura

```
┌─────────────────────┐    ┌─────────────────────┐
│   Máquina Windows   │    │        VM Linux     │
│                     │    │                     │
│  ├── Backend Python │◄──►│  ├── PostgreSQL     │
│  ├── Scripts        │    │  ├── Redis          │
│  └── Desenvolvimento│    │  ├── PgAdmin        │
│                     │    │  └── Redis Commander│
└─────────────────────┘    └─────────────────────┘
```

## 📋 Pré-requisitos

### Na VM (Linux)

- Docker e Docker Compose
- Porta 5432, 6379, 8080, 8081 liberadas no firewall
- IP fixo ou conhecimento do IP atual

### Na Máquina Windows

- Python 3.11+
- Git
- Editor de código (VS Code recomendado)

## 🚀 Configuração Passo a Passo

### 1. Configurar Infraestrutura na VM

```bash
# Na VM, clonar apenas os arquivos de infraestrutura
git clone <url-do-repositorio> bet-vm
cd bet-vm

# Subir apenas os serviços de infraestrutura
docker-compose -f docker-compose.infrastructure.yml up -d

# Verificar se os serviços estão rodando
docker-compose -f docker-compose.infrastructure.yml ps
```

### 2. Descobrir IP da VM

```bash
# Na VM, executar para descobrir o IP
ip addr show
# ou
hostname -I
# ou
ifconfig
```

Anote o IP da VM (exemplo: `192.168.1.100`)

### 3. Configurar Máquina Windows

```bash
# Na máquina Windows
git clone <url-do-repositorio> bet-local
cd bet-local

# Instalar dependências Python
cd backend
pip install -r requirements.txt
```

### 4. Configurar Conexão com VM

```bash
# Copiar arquivo de configuração
copy backend\.env.local backend\.env

# Editar o arquivo .env substituindo VM_IP_ADDRESS pelo IP real da VM
# Exemplo: se IP da VM é 192.168.1.100
# DATABASE_URL=postgresql://bet_user:bet_password@192.168.1.100:5432/bet_db
# REDIS_URL=redis://192.168.1.100:6379
```

### 5. Testar Conexão

```bash
# Testar conexão com banco (na máquina Windows)
cd backend
python -c "
from app.core.database import engine
try:
    conn = engine.connect()
    print('✅ Conexão com banco OK!')
    conn.close()
except Exception as e:
    print(f'❌ Erro: {e}')
"
```

### 6. Executar Backend Local

```bash
# Na máquina Windows
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 7. Popular Banco com Dados

```bash
# Na máquina Windows
cd ..
python scripts/seed_data.py
```

## 🌐 Acessos

### Serviços na VM

- **PostgreSQL**: `VM_IP:5432`
- **Redis**: `VM_IP:6379`
- **PgAdmin**: `http://VM_IP:8080` (admin@bet.com / admin123)
- **Redis Commander**: `http://VM_IP:8081`

### Serviços Locais

- **Backend API**: `http://localhost:8000`
- **API Docs**: `http://localhost:8000/api/v1/docs`

## 🔧 Comandos Úteis

### Na VM

```bash
# Ver logs dos serviços
docker-compose -f docker-compose.infrastructure.yml logs -f

# Parar serviços
docker-compose -f docker-compose.infrastructure.yml down

# Recriar volumes (CUIDADO: apaga dados)
docker-compose -f docker-compose.infrastructure.yml down -v

# Ver status
docker-compose -f docker-compose.infrastructure.yml ps
```

### Na Máquina Windows

```bash
# Executar backend
cd backend
uvicorn app.main:app --reload

# Executar worker Celery (opcional)
celery -A app.worker worker --loglevel=info

# Executar beat Celery (opcional)
celery -A app.worker beat --loglevel=info

# Testar conexões
python -c "from app.core.config import settings; print(f'DB: {settings.DATABASE_URL}')"
```

## 🐛 Solução de Problemas

### Erro de Conexão com Banco

```bash
# Verificar se PostgreSQL está rodando na VM
docker ps | grep postgres

# Verificar logs
docker logs bet_postgres

# Testar conexão direta
telnet VM_IP 5432
```

### Erro de Conexão com Redis

```bash
# Verificar se Redis está rodando na VM
docker ps | grep redis

# Testar conexão
telnet VM_IP 6379
```

### Firewall da VM

```bash
# Ubuntu/Debian - liberar portas
sudo ufw allow 5432
sudo ufw allow 6379
sudo ufw allow 8080
sudo ufw allow 8081

# CentOS/RHEL - liberar portas
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=6379/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

### Erro de Permissões Windows

```powershell
# Executar PowerShell como Administrador se necessário
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📊 Monitoramento

### PgAdmin (Gerenciar PostgreSQL)

1. Acesse: `http://VM_IP:8080`
2. Login: `admin@bet.com` / `admin123`
3. Adicione servidor:
   - Host: `db` (ou `VM_IP`)
   - Port: `5432`
   - Username: `bet_user`
   - Password: `bet_password`

### Redis Commander (Gerenciar Redis)

1. Acesse: `http://VM_IP:8081`
2. Explore keys, monitore performance

## 🎯 Vantagens desta Configuração

✅ **Desenvolvimento ágil**: Hot reload do Python local  
✅ **Debug facilitado**: IDE completo na máquina local  
✅ **Dados persistentes**: Banco na VM não é afetado por reinicializações  
✅ **Performance**: Acesso direto ao código Python  
✅ **Flexibilidade**: Pode alternar entre local e Docker facilmente

## 🔄 Alternando Configurações

### Para voltar ao Docker completo:

```bash
# Parar backend local
# Usar docker-compose.yml original
docker-compose up -d
```

### Para desenvolvimento híbrido:

- Mantenha infraestrutura na VM
- Backend pode rodar local ou Docker conforme necessidade

---

**Configuração**: ✅ Híbrida (Local + VM)  
**Complexidade**: ⭐⭐⚫⚫⚫ (Média)  
**Flexibilidade**: ⭐⭐⭐⭐⭐ (Máxima)
