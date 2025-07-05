# 🔧 Troubleshooting Windows - Bet Analytics

## 🐛 Problemas Comuns e Soluções

### ❌ Erro: "Cannot import 'setuptools.build_meta'"

**Problema**: Erro ao instalar NumPy ou outras dependências que precisam ser compiladas.

**Soluções**:

#### ✅ Solução 1: Usar Script Corrigido

```cmd
# Execute o script corrigido
scripts\setup_windows.bat

# Se ainda falhar, execute o script de correção
scripts\fix_windows_deps.bat
```

#### ✅ Solução 2: Instalar Build Tools

1. Baixe **Visual Studio Build Tools**:
   - https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Durante instalação, selecione:
   - ✅ **C++ build tools**
   - ✅ **Windows 10/11 SDK**
   - ✅ **CMake tools**

#### ✅ Solução 3: Usar Anaconda (Recomendado)

```cmd
# 1. Baixar Anaconda: https://www.anaconda.com/download
# 2. Instalar e abrir Anaconda Prompt
# 3. Criar ambiente:
conda create -n bet-analytics python=3.10
conda activate bet-analytics

# 4. Instalar pacotes científicos
conda install numpy pandas scikit-learn

# 5. Instalar demais dependências
pip install fastapi uvicorn sqlalchemy psycopg2-binary redis
```

#### ✅ Solução 4: Wheels Pré-compilados

1. Acesse: https://www.lfd.uci.edu/~gohlke/pythonlibs/
2. Baixe wheels para seu sistema:
   - `numpy‑xxx‑cp310‑cp310‑win_amd64.whl`
   - `pandas‑xxx‑cp310‑cp310‑win_amd64.whl`
3. Instale localmente:

```cmd
pip install caminho\para\numpy-xxx.whl
pip install caminho\para\pandas-xxx.whl
```

---

### ❌ Erro: Python não encontrado

**Problema**: `'python' is not recognized as an internal or external command`

**Solução**:

1. **Reinstalar Python**:

   - Baixe de: https://www.python.org/downloads/
   - ✅ Marque **"Add Python to PATH"**
   - ✅ Marque **"Install pip"**

2. **Verificar PATH manualmente**:

```cmd
# Adicionar ao PATH do sistema:
C:\Users\SeuUsuario\AppData\Local\Programs\Python\Python310\
C:\Users\SeuUsuario\AppData\Local\Programs\Python\Python310\Scripts\
```

3. **Testar**:

```cmd
python --version
pip --version
```

---

### ❌ Erro: Ambiente virtual não ativa

**Problema**: Script `.bat` não funciona ou ambiente não ativa.

**Solução**:

```cmd
# 1. Deletar ambiente existente
rmdir /s /q backend\venv

# 2. Recriar manualmente
cd backend
python -m venv venv

# 3. Ativar manualmente
venv\Scripts\activate.bat

# 4. Verificar se ativou (deve aparecer (venv) no prompt)
```

---

### ❌ Erro: Conexão com VM falha

**Problema**: `test_connection.bat` falha.

**Verificações**:

```cmd
# 1. VM está rodando?
ping IP_DA_VM

# 2. Portas estão abertas?
telnet IP_DA_VM 5432
telnet IP_DA_VM 6379

# 3. Firewall da VM
# Ubuntu: sudo ufw status
# CentOS: sudo firewall-cmd --list-all

# 4. IP correto no .env?
type backend\.env
```

**Soluções**:

```bash
# Na VM - liberar portas:
sudo ufw allow 5432
sudo ufw allow 6379
sudo ufw allow 8080
sudo ufw allow 8081

# Verificar se serviços estão rodando:
docker ps
docker-compose -f docker-compose.infrastructure.yml ps
```

---

### ❌ Erro: Backend não inicia

**Problema**: `run_backend.bat` falha ou API não responde.

**Diagnóstico**:

```cmd
# 1. Verificar instalação
check_install.bat

# 2. Verificar configuração
cd backend
call venv\Scripts\activate.bat
python -c "from app.core.config import settings; print(settings.DATABASE_URL)"

# 3. Testar imports
python -c "from app.main import app; print('✅ App OK')"
```

**Soluções**:

```cmd
# 1. Reinstalar dependências
cd backend
call venv\Scripts\activate.bat
pip install --upgrade -r requirements.txt

# 2. Verificar porta em uso
netstat -an | findstr 8000

# 3. Executar manualmente com logs
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

### ❌ Erro: Banco vazio após seed

**Problema**: `seed_database.bat` executa mas não há dados.

**Verificação**:

```cmd
# 1. Verificar se script executou
python scripts\seed_data.py

# 2. Verificar via PgAdmin
# Acesse: http://IP_VM:8080
# Login: admin@bet.com / admin123

# 3. Verificar conexão direta
cd backend
call venv\Scripts\activate.bat
python -c "
from app.core.database import SessionLocal
from app.models.team import Team
db = SessionLocal()
teams = db.query(Team).all()
print(f'Times encontrados: {len(teams)}')
"
```

---

### ❌ Erro: Permissões negadas

**Problema**: Scripts `.bat` não executam.

**Solução**:

```powershell
# 1. Executar PowerShell como Administrador
# 2. Alterar política de execução
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Ou executar comandos manualmente
```

---

## 🛠️ Scripts de Diagnóstico

### Verificar Instalação Completa

```cmd
check_install.bat
```

### Reparar Dependências

```cmd
scripts\fix_windows_deps.bat
```

### Testar Conexão VM

```cmd
test_connection.bat
```

### Verificar Serviços VM

```bash
# Na VM:
./check_services.sh
```

---

## 🔄 Reinstalação Completa

Se nada funcionar, reinstalação do zero:

```cmd
# 1. Remover ambiente
rmdir /s /q backend\venv

# 2. Reinstalar Python (opcional)
# Baixar de: https://www.python.org/downloads/

# 3. Executar setup novamente
scripts\setup_windows.bat

# 4. Se falhar, usar Anaconda
# Download: https://www.anaconda.com/download
```

---

## 📞 Suporte Adicional

### Informações para Debug

```cmd
# Coletar informações do sistema:
python --version
pip --version
echo %PATH%
systeminfo | findstr "OS"
```

### Logs Úteis

- **Setup**: Saída do `setup_windows.bat`
- **Backend**: Logs do `uvicorn`
- **VM**: `docker-compose logs`

### Links Úteis

- **Python Windows**: https://www.python.org/downloads/windows/
- **Visual C++ Build Tools**: https://visualstudio.microsoft.com/visual-cpp-build-tools/
- **Anaconda**: https://www.anaconda.com/download
- **Pre-compiled wheels**: https://www.lfd.uci.edu/~gohlke/pythonlibs/

---

**Status**: ✅ Guia completo de troubleshooting  
**Cobre**: 90% dos problemas comuns no Windows  
**Alternativas**: Múltiplas soluções para cada problema
