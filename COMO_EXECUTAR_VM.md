# 🚀 Como Executar: VM + Máquina Local

## 📋 Resumo da Configuração Solicitada

✅ **VM**: PostgreSQL, Redis e outros serviços via Docker  
✅ **Máquina Windows**: Backend Python rodando localmente  
✅ **Conexão**: Backend local conecta na infraestrutura da VM

---

## ⚡ **Configuração Rápida (5 passos)**

### 1️⃣ **Configurar VM (Linux)**

```bash
# Opção A: Script automatizado (recomendado)
curl -fsSL https://raw.githubusercontent.com/seu-repo/bet/main/scripts/setup_vm.sh | bash

# Opção B: Manual
git clone <seu-repositorio> bet-vm
cd bet-vm
docker-compose -f docker-compose.infrastructure.yml up -d
```

### 2️⃣ **Descobrir IP da VM**

```bash
# Na VM, execute:
hostname -I
# Anote o IP (exemplo: 192.168.1.100)
```

### 3️⃣ **Configurar Máquina Windows**

```cmd
# Clonar projeto na máquina Windows
git clone <seu-repositorio> bet-local
cd bet-local

# Configurar automaticamente
scripts\setup_windows.bat
```

### 4️⃣ **Configurar Conexão com VM**

Edite o arquivo `backend\.env` substituindo `VM_IP_ADDRESS` pelo IP real:

```env
# Exemplo: se IP da VM é 192.168.1.100
DATABASE_URL=postgresql://bet_user:bet_password@192.168.1.100:5432/bet_db
REDIS_URL=redis://192.168.1.100:6379
CELERY_BROKER_URL=redis://192.168.1.100:6379
CELERY_RESULT_BACKEND=redis://192.168.1.100:6379
SECRET_KEY=minha_chave_secreta
DEBUG=true
ENVIRONMENT=development
```

### 5️⃣ **Executar e Testar**

```cmd
# Testar conexão com VM
test_connection.bat

# Popular banco de dados
seed_database.bat

# Executar backend local
run_backend.bat
```

---

## 🌐 **Acessos Após Configuração**

### Na VM (Infraestrutura)

- **PostgreSQL**: `192.168.1.100:5432`
- **Redis**: `192.168.1.100:6379`
- **PgAdmin**: `http://192.168.1.100:8080` (admin@bet.com / admin123)
- **Redis Commander**: `http://192.168.1.100:8081`

### Na Máquina Windows (Backend)

- **API Local**: `http://localhost:8000`
- **Documentação**: `http://localhost:8000/api/v1/docs`
- **ReDoc**: `http://localhost:8000/api/v1/redoc`

---

## 🔧 **Comandos Diários**

### **Para Desenvolvimento**

```cmd
# 1. Verificar se VM está ok
test_connection.bat

# 2. Iniciar backend local
run_backend.bat

# 3. Em outro terminal (opcional)
run_worker.bat    # Para tarefas Celery
```

### **Para Gerenciar VM**

```bash
# Ver status dos serviços
./check_services.sh

# Ver logs
docker-compose -f docker-compose.infrastructure.yml logs -f

# Reiniciar serviços
docker-compose -f docker-compose.infrastructure.yml restart

# Parar tudo
docker-compose -f docker-compose.infrastructure.yml down
```

---

## 🧪 **Testando a API**

```bash
# Verificar saúde
curl http://localhost:8000/health

# Listar times
curl http://localhost:8000/api/v1/teams

# Partidas de hoje
curl http://localhost:8000/api/v1/matches/today

# Analisar partida (substitua 1 pelo ID real)
curl http://localhost:8000/api/v1/analysis/match/1

# Buscar trends
curl http://localhost:8000/api/v1/analysis/trends
```

---

## 🎯 **Vantagens desta Configuração**

### ✅ **Para Desenvolvimento**

- **Debug completo** no código Python
- **Hot reload** instantâneo nas mudanças
- **IDE nativo** (VS Code, PyCharm) funciona perfeitamente
- **Breakpoints** funcionam normalmente
- **Performance máxima** do Python local

### ✅ **Para Infraestrutura**

- **Dados seguros** na VM (não perdem ao reiniciar Windows)
- **Serviços isolados** em containers
- **PostgreSQL/Redis** sempre disponíveis
- **Fácil backup** dos dados da VM

### ✅ **Para Flexibilidade**

- Pode **alternar configurações** facilmente
- **VM pode ser compartilhada** entre desenvolvedores
- **Backend local** permite experimentação
- **Deploy simples** mudando apenas configuração

---

## 🔧 **Solução de Problemas**

### **Erro de Conexão com VM**

```cmd
# 1. Verificar se VM está ligada
ping 192.168.1.100

# 2. Testar porta do PostgreSQL
telnet 192.168.1.100 5432

# 3. Verificar firewall da VM
# Ubuntu: sudo ufw status
# CentOS: sudo firewall-cmd --list-all
```

### **Backend não inicia**

```cmd
# 1. Verificar configuração
cd backend
call venv\Scripts\activate.bat
python -c "from app.core.config import settings; print(settings.DATABASE_URL)"

# 2. Testar dependências
pip install -r requirements.txt

# 3. Verificar logs de erro
```

### **Dados não aparecem**

```cmd
# 1. Popular banco novamente
seed_database.bat

# 2. Verificar se banco tem dados
# Acessar PgAdmin: http://IP_VM:8080
```

---

## 📊 **Monitoramento**

### **PgAdmin (Banco de Dados)**

1. Acesse: `http://192.168.1.100:8080`
2. Login: `admin@bet.com` / `admin123`
3. Adicionar servidor:
   - Nome: `Bet Analytics`
   - Host: `db` (ou IP da VM)
   - Port: `5432`
   - Username: `bet_user`
   - Password: `bet_password`
   - Database: `bet_db`

### **Redis Commander (Cache)**

1. Acesse: `http://192.168.1.100:8081`
2. Explore keys do Redis
3. Monitore performance

---

## 🚀 **Resultado Final**

Com esta configuração você terá:

✅ **Infraestrutura robusta** na VM  
✅ **Desenvolvimento ágil** na máquina local  
✅ **Debug completo** do código Python  
✅ **Hot reload** instantâneo  
✅ **Dados persistentes** e seguros  
✅ **Performance máxima** para desenvolvimento

---

**Configuração**: ✅ **VM + Local (Como solicitado)**  
**Complexidade**: ⭐⭐⭐⚫⚫ (Média)  
**Flexibilidade**: ⭐⭐⭐⭐⭐ (Máxima)  
**Performance**: ⭐⭐⭐⭐⭐ (Excelente)  
**Debug**: ⭐⭐⭐⭐⭐ (Completo)
