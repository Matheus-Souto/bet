# 🚀 Como Executar: VM + Máquina Local

## 📋 Resumo da Configuração Solicitada

✅ **VM**: PostgreSQL, Redis e outros serviços via Docker  
✅ **Máquina Windows**: Backend Python rodando localmente  
✅ **Conexão**: Backend local conecta na infraestrutura da VM

---

## 🔧 Pré-requisitos

### VM Linux:

- Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- Pelo menos 2GB RAM
- Conexão com a internet
- Acesso via SSH (opcional)

### Máquina Windows:

- Python 3.9+ instalado
- Git instalado
- Acesso de rede à VM

## 🚀 Configuração da VM

### Opção 1: Script Automático (Recomendado)

1. **Faça download do script na VM:**

```bash
# Se tiver git instalado
git clone <repo-url>
cd bet/scripts

# Ou baixe apenas o script
wget https://raw.githubusercontent.com/your-repo/bet/main/scripts/setup_vm_fixed.sh
chmod +x setup_vm_fixed.sh
```

2. **Execute o script:**

```bash
./setup_vm_fixed.sh
```

### ⚠️ Resolvendo Problemas de Permissão Docker

Se você vir o erro **"permission denied while trying to connect to the Docker daemon"**, siga estes passos:

#### Solução Rápida:

```bash
# Baixar script de correção
wget https://raw.githubusercontent.com/your-repo/bet/main/scripts/fix_vm_docker.sh
chmod +x fix_vm_docker.sh

# Executar correção
./fix_vm_docker.sh

# Aplicar permissões (escolha UMA opção):
# Opção 1: Comando newgrp
newgrp docker

# Opção 2: Logout/Login
exit
# (faça login novamente)

# Opção 3: Reiniciar VM
sudo reboot
```

#### Solução Manual:

```bash
# 1. Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# 2. Verificar se foi adicionado
groups $USER

# 3. Aplicar as mudanças (escolha uma):
newgrp docker          # Ou
logout && login        # Ou
sudo reboot           # Reiniciar VM
```

### Opção 2: Configuração Manual

Se preferir fazer a configuração passo a passo:

1. **Instalar Docker:**

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Fazer logout/login ou executar: newgrp docker
```

2. **Instalar Docker Compose:**

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. **Configurar Firewall:**

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 5432 comment "PostgreSQL"
sudo ufw allow 6379 comment "Redis"
sudo ufw allow 8080 comment "PgAdmin"
sudo ufw allow 8081 comment "Redis Commander"

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=6379/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

4. **Criar diretório do projeto:**

```bash
mkdir ~/bet-analytics-vm
cd ~/bet-analytics-vm
```

5. **Criar docker-compose.infrastructure.yml:**

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  db:
    image: postgres:15
    container_name: bet_postgres
    environment:
      POSTGRES_USER: bet_user
      POSTGRES_PASSWORD: bet_password
      POSTGRES_DB: bet_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'
    networks:
      - bet_network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: bet_redis
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/data
    networks:
      - bet_network
    restart: unless-stopped

  # PgAdmin (Opcional)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: bet_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@bet.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - '8080:80'
    networks:
      - bet_network
    restart: unless-stopped
    depends_on:
      - db

  # Redis Commander (Opcional)
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: bet_redis_commander
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - '8081:8081'
    networks:
      - bet_network
    restart: unless-stopped
    depends_on:
      - redis

volumes:
  postgres_data:
  redis_data:

networks:
  bet_network:
    driver: bridge
```

6. **Iniciar os serviços:**

```bash
# Se Docker está configurado sem sudo:
docker-compose -f docker-compose.infrastructure.yml up -d

# Se precisar usar sudo:
sudo docker-compose -f docker-compose.infrastructure.yml up -d
```

## 📊 Verificando os Serviços

### Comando para verificar status:

```bash
# Verificar containers
docker ps
# ou com sudo: sudo docker ps

# Verificar logs
docker-compose -f docker-compose.infrastructure.yml logs -f
# ou com sudo: sudo docker-compose -f docker-compose.infrastructure.yml logs -f

# Verificar IP da VM
hostname -I
```

### Testar conexões:

```bash
# Testar PostgreSQL
nc -zv localhost 5432

# Testar Redis
nc -zv localhost 6379
```

## 🌐 Informações de Conexão

Após a configuração, anote estas informações:

- **IP da VM**: `[IP_DA_VM]` (ex: 192.168.1.100)
- **PostgreSQL**: `[IP_DA_VM]:5432`
  - Database: `bet_db`
  - User: `bet_user`
  - Password: `bet_password`
- **Redis**: `[IP_DA_VM]:6379`
- **PgAdmin**: `http://[IP_DA_VM]:8080`
  - Email: admin@bet.com
  - Password: admin123
- **Redis Commander**: `http://[IP_DA_VM]:8081`

## 💻 Configuração do Windows

Agora configure sua máquina Windows para conectar na VM:

### 1. Execute o script de configuração:

```cmd
# No diretório do projeto
scripts\setup_windows.bat
```

### 2. Configure as variáveis de ambiente:

Crie arquivo `.env.local`:

```env
# Configuração para VM
DATABASE_URL=postgresql://bet_user:bet_password@[IP_DA_VM]:5432/bet_db
REDIS_URL=redis://[IP_DA_VM]:6379

# Configurações locais
ENVIRONMENT=development
DEBUG=true
```

**Substitua `[IP_DA_VM]` pelo IP real da sua VM!**

### 3. Teste a conexão:

```cmd
test_connection.bat
```

### 4. Execute o backend:

```cmd
run_backend.bat
```

## 🛠️ Comandos Úteis na VM

### Gerenciar serviços:

```bash
# Parar todos os serviços
docker-compose -f docker-compose.infrastructure.yml down

# Iniciar todos os serviços
docker-compose -f docker-compose.infrastructure.yml up -d

# Reiniciar serviços
docker-compose -f docker-compose.infrastructure.yml restart

# Ver logs em tempo real
docker-compose -f docker-compose.infrastructure.yml logs -f

# Ver apenas logs do PostgreSQL
docker-compose -f docker-compose.infrastructure.yml logs -f db

# Ver apenas logs do Redis
docker-compose -f docker-compose.infrastructure.yml logs -f redis
```

### Gerenciar dados:

```bash
# Fazer backup do banco
docker exec bet_postgres pg_dump -U bet_user bet_db > backup.sql

# Conectar ao PostgreSQL
docker exec -it bet_postgres psql -U bet_user -d bet_db

# Conectar ao Redis
docker exec -it bet_redis redis-cli
```

### Monitoramento:

```bash
# Ver uso de recursos
docker stats

# Verificar espaço em disco
df -h
docker system df
```

## 🔄 Scripts Automáticos Disponíveis

Se você usou o script automático, estes scripts estarão disponíveis na VM:

- `./check_services.sh` - Verificar status dos serviços
- `./fix_docker_permissions.sh` - Corrigir permissões Docker
- `./setup_vm_fixed.sh` - Script principal de configuração

## ❌ Resolução de Problemas

### Erro: "permission denied while trying to connect to the Docker daemon"

**Solução:**

```bash
# 1. Execute o script de correção
./fix_docker_permissions.sh

# 2. Aplique as permissões (escolha uma opção):
newgrp docker
# OU faça logout/login
# OU reinicie a VM
```

### Erro: Porta já está em uso

**Solução:**

```bash
# Verificar o que está usando a porta
sudo netstat -tlnp | grep :5432

# Parar o serviço
sudo systemctl stop postgresql
```

### Erro: Containers não iniciam

**Soluções:**

```bash
# 1. Verificar logs
docker-compose -f docker-compose.infrastructure.yml logs

# 2. Limpar e reiniciar
docker-compose -f docker-compose.infrastructure.yml down
docker system prune -f
docker-compose -f docker-compose.infrastructure.yml up -d

# 3. Verificar recursos
free -h
df -h
```

### VM não está acessível do Windows

**Soluções:**

1. Verificar firewall da VM
2. Verificar firewall do Windows
3. Testar ping: `ping [IP_DA_VM]`
4. Verificar configuração de rede da VM

### Backend Windows não conecta na VM

**Soluções:**

1. Verificar se IP está correto no `.env.local`
2. Executar `test_connection.bat`
3. Verificar se as portas estão abertas na VM
4. Verificar se os serviços estão rodando: `./check_services.sh`

## 📞 Suporte

Se continuar com problemas:

1. Execute `./check_services.sh` na VM
2. Execute `test_connection.bat` no Windows
3. Verifique os logs: `docker-compose -f docker-compose.infrastructure.yml logs -f`
4. Verifique a documentação: `docs/TROUBLESHOOTING_WINDOWS.md`

## ✅ Próximos Passos

Com a configuração híbrida funcionando:

1. ✅ VM configurada com PostgreSQL e Redis
2. ✅ Windows configurado para desenvolvimento
3. ✅ Conexão entre VM e Windows funcionando
4. 🚀 Pronto para desenvolver!

Agora você pode:

- Acessar a API em: `http://localhost:8000`
- Ver documentação em: `http://localhost:8000/docs`
- Gerenciar banco via PgAdmin: `http://[IP_DA_VM]:8080`
- Monitorar Redis: `http://[IP_DA_VM]:8081`

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
