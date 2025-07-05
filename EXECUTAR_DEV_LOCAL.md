# 🚀 Execução Rápida - Desenvolvimento Local + VM

Esta configuração permite máxima flexibilidade: infraestrutura na VM, código Python local.

## ⚡ Setup Rápido

### 1. Configurar VM (Uma vez)

```bash
# Na VM Linux, executar:
curl -fsSL https://raw.githubusercontent.com/seu-usuario/bet-analytics/main/scripts/setup_vm.sh | bash

# OU manualmente:
git clone <repositorio> bet-vm
cd bet-vm
docker-compose -f docker-compose.infrastructure.yml up -d
```

### 2. Configurar Windows (Uma vez)

```cmd
# Na máquina Windows:
git clone <repositorio> bet-local
cd bet-local
scripts\setup_windows.bat
```

### 3. Descobrir IP da VM

```bash
# Na VM:
hostname -I
# Anote o IP (ex: 192.168.1.100)
```

### 4. Configurar Conexão

```cmd
# Editar arquivo backend\.env:
DATABASE_URL=postgresql://bet_user:bet_password@192.168.1.100:5432/bet_db
REDIS_URL=redis://192.168.1.100:6379
```

### 5. Executar e Testar

```cmd
# Testar conexão:
test_connection.bat

# Popular banco:
seed_database.bat

# Executar backend:
run_backend.bat
```

## 🌐 Acessos

- **API Local**: http://localhost:8000
- **Docs**: http://localhost:8000/api/v1/docs
- **PgAdmin (VM)**: http://IP_DA_VM:8080
- **Redis Commander (VM)**: http://IP_DA_VM:8081

## 🔧 Comandos Diários

### Na VM

```bash
# Ver status
./check_services.sh

# Ver logs
docker-compose -f docker-compose.infrastructure.yml logs -f

# Reiniciar se necessário
docker-compose -f docker-compose.infrastructure.yml restart
```

### No Windows

```cmd
# Backend principal
run_backend.bat

# Worker (opcional)
run_worker.bat

# Beat scheduler (opcional)
run_beat.bat
```

## 🎯 Vantagens

✅ **Debug total** no código Python  
✅ **Hot reload** instantâneo  
✅ **IDE completo** na máquina local  
✅ **Dados persistentes** na VM  
✅ **Performance máxima** para desenvolvimento

## 🔄 Troubleshooting

### Erro de Conexão

1. Verificar se VM está ligada
2. Verificar IP da VM: `hostname -I`
3. Testar conexão: `telnet IP_VM 5432`
4. Verificar firewall da VM

### Backend não inicia

1. Verificar se .env está configurado
2. Executar `test_connection.bat`
3. Verificar logs no terminal

### Performance lenta

1. Verificar latência de rede para VM
2. Considerar usar VM local (VirtualBox/VMware)
3. Otimizar conexão de rede

---

**Configuração**: ✅ Híbrida (Local + VM)  
**Complexidade**: ⭐⭐⚫⚫⚫  
**Performance**: ⭐⭐⭐⭐⭐  
**Flexibilidade**: ⭐⭐⭐⭐⭐
