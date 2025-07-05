# Resolver Problemas de Docker na VM

## 🔴 Problema Identificado

Você está vendo este erro na VM:

```
permission denied while trying to connect to the Docker daemon socket
```

## 🎯 Causa do Problema

Este é um problema **muito comum** de permissões do Docker. O usuário atual não está no grupo `docker`, então não consegue executar comandos Docker sem `sudo`.

## ⚡ Solução Rápida (Método 1)

Execute estes comandos **na VM**:

```bash
# 1. Baixar script de correção rápida
curl -fsSL https://raw.githubusercontent.com/your-repo/bet/main/scripts/fix_vm_docker.sh -o fix_vm_docker.sh
chmod +x fix_vm_docker.sh

# 2. Executar o script
./fix_vm_docker.sh

# 3. Aplicar permissões (ESCOLHA UMA OPÇÃO):

# Opção A: Comando newgrp (mais rápido)
newgrp docker

# Opção B: Logout e Login novamente
exit
# (faça login novamente via SSH ou console)

# Opção C: Reiniciar a VM (mais garantido)
sudo reboot
```

## 🔧 Solução Manual (Método 2)

Se preferir fazer manualmente:

```bash
# 1. Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# 2. Verificar se foi adicionado
groups $USER
# Deve aparecer "docker" na lista

# 3. Aplicar as mudanças (escolha uma):
newgrp docker          # Aplicar na sessão atual
# OU
logout && login        # Logout/login
# OU
sudo reboot           # Reiniciar VM
```

## 🧪 Testar se Funcionou

Após aplicar a solução:

```bash
# Teste 1: Docker sem sudo
docker --version

# Teste 2: Listar containers
docker ps

# Teste 3: Docker Compose
docker-compose --version

# Se tudo funcionou, continue com:
docker-compose -f docker-compose.infrastructure.yml up -d
```

## 🔄 Script Automático Corrigido

Se você quiser executar o setup completo novamente, use a versão corrigida:

```bash
# Baixar versão corrigida
curl -fsSL https://raw.githubusercontent.com/your-repo/bet/main/scripts/setup_vm_fixed.sh -o setup_vm_fixed.sh
chmod +x setup_vm_fixed.sh

# Executar
./setup_vm_fixed.sh
```

Este script corrigido:

- ✅ Detecta automaticamente se precisa de sudo
- ✅ Adiciona usuário ao grupo docker
- ✅ Avisa sobre logout/login
- ✅ Funciona mesmo sem permissões Docker

## 📋 Verificar se Está Tudo OK

Execute estes comandos para verificar:

```bash
# 1. Verificar grupos do usuário
groups $USER

# 2. Verificar se Docker está rodando
sudo systemctl status docker

# 3. Testar Docker sem sudo
docker ps

# 4. Verificar containers do projeto
docker-compose -f docker-compose.infrastructure.yml ps

# 5. Testar conexões
nc -zv localhost 5432  # PostgreSQL
nc -zv localhost 6379  # Redis
```

## 🌐 Obter Informações de Conexão

Após resolver o problema:

```bash
# Obter IP da VM
hostname -I

# Verificar portas abertas
ss -tlnp | grep -E ":(5432|6379|8080|8081)"

# Verificar status dos serviços
docker-compose -f docker-compose.infrastructure.yml ps
```

## ❌ Se o Problema Persistir

### Opção 1: Usar sudo temporariamente

```bash
# Executar comandos com sudo
sudo docker-compose -f docker-compose.infrastructure.yml up -d
sudo docker ps
```

### Opção 2: Verificar se Docker está instalado corretamente

```bash
# Reinstalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Opção 3: Verificar logs do Docker

```bash
# Ver logs do serviço Docker
sudo journalctl -u docker.service

# Reiniciar serviço Docker
sudo systemctl restart docker
```

### Opção 4: Verificar configuração do grupo

```bash
# Ver informações do grupo docker
getent group docker

# Forçar recriação do grupo (último recurso)
sudo groupdel docker
sudo groupadd docker
sudo usermod -aG docker $USER
```

## ✅ Próximos Passos

Após resolver o problema de permissões:

1. ✅ Docker funcionando sem sudo
2. ✅ Containers rodando
3. ✅ Portas acessíveis (5432, 6379, 8080, 8081)
4. 🚀 Anotar IP da VM
5. 🖥️ Configurar máquina Windows

### Configure Windows agora:

1. Anote o IP da VM: `[SEU_IP_AQUI]`
2. No Windows, execute: `scripts\setup_windows.bat`
3. Edite `.env.local` com o IP da VM
4. Teste: `test_connection.bat`
5. Execute: `run_backend.bat`

## 🆘 Ainda com Problema?

Se nada funcionou:

1. **Verifique a distribuição Linux:**

   ```bash
   cat /etc/os-release
   ```

2. **Para CentOS/RHEL, use:**

   ```bash
   # CentOS/RHEL usa grupos diferentes
   sudo usermod -aG dockerroot $USER
   ```

3. **Para sistemas com SELinux:**

   ```bash
   # Verificar SELinux
   sestatus

   # Configurar contexto SELinux para Docker
   sudo setsebool -P container_manage_cgroup on
   ```

4. **Entre em contato com suporte** com:
   - Distribuição Linux (`cat /etc/os-release`)
   - Versão Docker (`docker --version`)
   - Logs do erro (`sudo journalctl -u docker`)
   - Output do comando `groups $USER`

---

## 📝 Resumo

**Problema**: "permission denied while trying to connect to the Docker daemon"  
**Solução**: Adicionar usuário ao grupo docker e fazer logout/login  
**Comando Rápido**: `sudo usermod -aG docker $USER && newgrp docker`  
**Verificação**: `docker ps` (deve funcionar sem sudo)
