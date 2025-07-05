# ⚡ Configuração Híbrida: Local + VM - IMPLEMENTADA

## 🎯 O Que Foi Criado

Implementei uma configuração **híbrida** que permite máxima flexibilidade para desenvolvimento:

- **Infraestrutura (PostgreSQL, Redis)**: Roda na VM via Docker
- **Backend Python**: Roda localmente na máquina Windows
- **Dados persistentes**: Ficam seguros na VM
- **Debug completo**: Acesso total ao código Python local

## 📁 Arquivos Criados

### Para a VM (Infraestrutura)

- `docker-compose.infrastructure.yml` - Apenas PostgreSQL, Redis, PgAdmin, Redis Commander
- `scripts/setup_vm.sh` - Script automatizado para configurar a VM
- `docs/SETUP_DEV_LOCAL.md` - Documentação completa

### Para Windows (Desenvolvimento Local)

- `backend/.env.local` - Template de configuração
- `scripts/setup_windows.bat` - Script automatizado para Windows
- `EXECUTAR_DEV_LOCAL.md` - Guia rápido de execução

### Configurações Atualizadas

- `backend/app/core/config.py` - Suporte para desenvolvimento híbrido
- Scripts de automação para iniciar serviços

## 🚀 Como Usar Agora

### 1. Na VM Linux

```bash
# Opção 1: Script automatizado
curl -fsSL https://raw.githubusercontent.com/seu-repo/bet/main/scripts/setup_vm.sh | bash

# Opção 2: Manual
git clone <seu-repositorio> bet-vm
cd bet-vm
docker-compose -f docker-compose.infrastructure.yml up -d
```

### 2. Na Máquina Windows

```cmd
# Clonar projeto
git clone <seu-repositorio> bet-local
cd bet-local

# Configurar automaticamente
scripts\setup_windows.bat

# Descobrir IP da VM e configurar backend\.env
# DATABASE_URL=postgresql://bet_user:bet_password@IP_DA_VM:5432/bet_db
# REDIS_URL=redis://IP_DA_VM:6379
```

### 3. Executar e Testar

```cmd
# Testar conexão com VM
test_connection.bat

# Popular banco de dados
seed_database.bat

# Executar backend local
run_backend.bat
```

## 🌐 Serviços e Acessos

### Na VM

- **PostgreSQL**: `VM_IP:5432`
- **Redis**: `VM_IP:6379`
- **PgAdmin**: `http://VM_IP:8080` (admin@bet.com / admin123)
- **Redis Commander**: `http://VM_IP:8081`

### Local (Windows)

- **API Backend**: `http://localhost:8000`
- **Documentação**: `http://localhost:8000/api/v1/docs`
- **Código Python**: Acesso total para debug/development

## 🛠️ Scripts Automatizados Criados

### VM (Linux)

- `setup_vm.sh` - Configura Docker, firewall, serviços
- `check_services.sh` - Verifica status dos serviços

### Windows

- `setup_windows.bat` - Configura Python, venv, dependências
- `run_backend.bat` - Inicia backend local
- `run_worker.bat` - Inicia Celery worker
- `run_beat.bat` - Inicia Celery beat
- `seed_database.bat` - Popula banco com dados
- `test_connection.bat` - Testa conexão com VM

## 🎯 Vantagens da Configuração

### ✅ Benefícios

- **Debug Completo**: Acesso total ao código Python
- **Hot Reload**: Mudanças instantâneas no código
- **IDE Nativo**: VS Code, PyCharm funcionam perfeitamente
- **Dados Seguros**: PostgreSQL na VM, dados persistentes
- **Performance**: Zero overhead do Docker no Python
- **Flexibilidade**: Pode alternar entre configurações

### 🔄 Casos de Uso

- **Desenvolvimento diário**: Backend local + VM
- **Testing/Deploy**: Docker completo
- **Debugging**: Local com breakpoints
- **Produção**: Docker em servidor

## 📊 Comparação de Configurações

| Aspecto           | Docker Completo | Híbrido (Local + VM) | Local Completo |
| ----------------- | --------------- | -------------------- | -------------- |
| **Setup**         | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⚫⚫           | ⭐⚫⚫⚫⚫     |
| **Debug**         | ⭐⭐⚫⚫⚫      | ⭐⭐⭐⭐⭐           | ⭐⭐⭐⭐⭐     |
| **Performance**   | ⭐⭐⭐⚫⚫      | ⭐⭐⭐⭐⭐           | ⭐⭐⭐⭐⭐     |
| **Isolamento**    | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐⚫           | ⭐⚫⚫⚫⚫     |
| **Flexibilidade** | ⭐⭐⭐⚫⚫      | ⭐⭐⭐⭐⭐           | ⭐⭐⚫⚫⚫     |

## 🔧 Comandos de Manutenção

### Diários (Windows)

```cmd
run_backend.bat      # Iniciar desenvolvimento
test_connection.bat  # Verificar se VM está ok
```

### VM Management

```bash
./check_services.sh  # Status dos serviços
docker-compose -f docker-compose.infrastructure.yml logs -f  # Logs
docker-compose -f docker-compose.infrastructure.yml restart  # Reiniciar
```

### Troubleshooting

```cmd
# Se conexão falhar
ping IP_DA_VM
telnet IP_DA_VM 5432

# Se backend não iniciar
cd backend
call venv\Scripts\activate.bat
python -c "from app.core.config import settings; print(settings.DATABASE_URL)"
```

## 🎉 Resultado Final

Esta configuração híbrida oferece o **melhor dos dois mundos**:

✅ **Simplicidade da VM** para infraestrutura  
✅ **Poder do desenvolvimento local** para código  
✅ **Escalabilidade** para produção  
✅ **Flexibilidade** para diferentes cenários

O projeto agora suporta **3 modos de execução**:

1. **Docker Completo**: `docker-compose up -d`
2. **Híbrido**: Infraestrutura na VM + Backend local
3. **Local**: Tudo rodando localmente

---

**Status**: ✅ **CONFIGURAÇÃO HÍBRIDA IMPLEMENTADA**  
**Complexidade**: ⭐⭐⭐⚫⚫ (Média)  
**Flexibilidade**: ⭐⭐⭐⭐⭐ (Máxima)  
**Pronto para**: Desenvolvimento avançado
