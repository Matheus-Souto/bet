@echo off
REM Script para configurar desenvolvimento local no Windows
REM Execute este script na máquina Windows

echo 🚀 Configurando desenvolvimento local no Windows...
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python não encontrado. Instale Python 3.9+ primeiro.
    echo Baixe em: https://www.python.org/downloads/
    echo.
    echo ⚠️  IMPORTANTE: Durante a instalação do Python:
    echo    - Marque "Add Python to PATH"
    echo    - Marque "Install pip"
    pause
    exit /b 1
) else (
    echo ✅ Python encontrado
    python --version
)

REM Verificar versão do Python (mínimo 3.9)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set python_version=%%v
echo Versão do Python: %python_version%

REM Verificar se pip está instalado
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip não encontrado
    echo Reinstale o Python com pip incluído
    pause
    exit /b 1
) else (
    echo ✅ pip encontrado
)

REM Entrar no diretório backend
if not exist "backend" (
    echo ❌ Diretório backend não encontrado
    echo Execute este script na raiz do projeto
    pause
    exit /b 1
)

cd backend

REM Remover ambiente virtual existente se houver problemas
if exist "venv" (
    echo 🗑️  Removendo ambiente virtual existente...
    rmdir /s /q venv
)

REM Criar ambiente virtual
echo 📦 Criando novo ambiente virtual...
python -m venv venv

if %errorlevel% neq 0 (
    echo ❌ Erro ao criar ambiente virtual
    echo Certifique-se de que o Python está instalado corretamente
    pause
    exit /b 1
) else (
    echo ✅ Ambiente virtual criado
)

REM Ativar ambiente virtual
echo 🔄 Ativando ambiente virtual...
call venv\Scripts\activate.bat

if %errorlevel% neq 0 (
    echo ❌ Erro ao ativar ambiente virtual
    pause
    exit /b 1
)

REM Atualizar pip, setuptools e wheel primeiro
echo 📦 Atualizando ferramentas de build...
python -m pip install --upgrade pip setuptools wheel

if %errorlevel% neq 0 (
    echo ❌ Erro ao atualizar ferramentas de build
    pause
    exit /b 1
) else (
    echo ✅ Ferramentas de build atualizadas
)

REM Instalar dependências críticas primeiro
echo 📦 Instalando dependências críticas...
pip install setuptools>=65.0.0 wheel>=0.37.0 pip>=21.0.0

REM Instalar NumPy primeiro (evita problemas de dependência)
echo 📦 Instalando NumPy...
pip install "numpy>=1.21.0,<2.0.0"

if %errorlevel% neq 0 (
    echo ⚠️  Erro ao instalar NumPy. Tentando versão alternativa...
    pip install numpy --only-binary=all
    
    if %errorlevel% neq 0 (
        echo ❌ Não foi possível instalar NumPy
        echo.
        echo Soluções possíveis:
        echo 1. Instale o Microsoft Visual C++ Build Tools
        echo 2. Ou baixe NumPy pré-compilado do https://www.lfd.uci.edu/~gohlke/pythonlibs/
        echo 3. Ou use Python 3.9-3.11 que tem melhor compatibilidade
        pause
        exit /b 1
    )
)

REM Instalar pandas
echo 📦 Instalando Pandas...
pip install "pandas>=1.5.0,<3.0.0" --only-binary=all

REM Instalar outras dependências
echo 📦 Instalando demais dependências...
pip install -r requirements.txt --only-binary=all

if %errorlevel% neq 0 (
    echo ⚠️  Algumas dependências falharam. Tentando instalação alternativa...
    
    REM Tentar instalar sem versões específicas
    echo 📦 Instalando dependências básicas...
    pip install fastapi uvicorn pydantic sqlalchemy psycopg2-binary redis
    pip install httpx requests python-dotenv celery beautifulsoup4
    pip install pydantic-settings pytest python-dateutil loguru
    
    if %errorlevel% neq 0 (
        echo ❌ Erro crítico na instalação de dependências
        echo.
        echo Verifique:
        echo 1. Conexão com internet
        echo 2. Firewall/Antivirus bloqueando pip
        echo 3. Versão do Python (use 3.9-3.11)
        pause
        exit /b 1
    ) else (
        echo ✅ Dependências básicas instaladas
    )
) else (
    echo ✅ Todas dependências instaladas com sucesso
)

REM Voltar ao diretório raiz
cd ..

REM Configurar arquivo .env
if not exist "backend\.env" (
    echo 📝 Criando arquivo de configuração...
    echo # Configuração Local - Substitua VM_IP_ADDRESS pelo IP da VM > backend\.env
    echo DATABASE_URL=postgresql://bet_user:bet_password@VM_IP_ADDRESS:5432/bet_db >> backend\.env
    echo REDIS_URL=redis://VM_IP_ADDRESS:6379 >> backend\.env
    echo CELERY_BROKER_URL=redis://VM_IP_ADDRESS:6379 >> backend\.env
    echo CELERY_RESULT_BACKEND=redis://VM_IP_ADDRESS:6379 >> backend\.env
    echo SECRET_KEY=minha_chave_secreta_local >> backend\.env
    echo DEBUG=true >> backend\.env
    echo ENVIRONMENT=development >> backend\.env
    echo ⚠️  IMPORTANTE: Edite o arquivo backend\.env e substitua VM_IP_ADDRESS pelo IP real da VM
) else (
    echo ✅ Arquivo .env já existe
)

REM Criar script para executar o backend
echo @echo off > run_backend.bat
echo echo 🚀 Iniciando backend local... >> run_backend.bat
echo cd backend >> run_backend.bat
echo call venv\Scripts\activate.bat >> run_backend.bat
echo echo ✅ Ambiente ativado. Iniciando servidor... >> run_backend.bat
echo uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 >> run_backend.bat
echo pause >> run_backend.bat

REM Criar script para executar worker
echo @echo off > run_worker.bat
echo echo 🔄 Iniciando worker Celery... >> run_worker.bat
echo cd backend >> run_worker.bat
echo call venv\Scripts\activate.bat >> run_worker.bat
echo celery -A app.worker worker --loglevel=info >> run_worker.bat
echo pause >> run_worker.bat

REM Criar script para executar beat
echo @echo off > run_beat.bat
echo echo ⏰ Iniciando beat Celery... >> run_beat.bat
echo cd backend >> run_beat.bat
echo call venv\Scripts\activate.bat >> run_beat.bat
echo celery -A app.worker beat --loglevel=info >> run_beat.bat
echo pause >> run_beat.bat

REM Criar script para popular banco
echo @echo off > seed_database.bat
echo echo 🌱 Populando banco de dados... >> seed_database.bat
echo cd backend >> seed_database.bat
echo call venv\Scripts\activate.bat >> seed_database.bat
echo cd .. >> seed_database.bat
echo python scripts\seed_data.py >> seed_database.bat
echo pause >> seed_database.bat

REM Criar script para testar conexão
echo @echo off > test_connection.bat
echo echo 🔍 Testando conexão com VM... >> test_connection.bat
echo cd backend >> test_connection.bat
echo call venv\Scripts\activate.bat >> test_connection.bat
echo python -c "from app.core.database import engine; conn = engine.connect(); print('✅ Conexão OK!'); conn.close()" >> test_connection.bat
echo if %%errorlevel%% neq 0 ^( >> test_connection.bat
echo     echo ❌ Erro de conexão. Verifique se a VM está rodando e o IP está correto no .env >> test_connection.bat
echo ^) >> test_connection.bat
echo pause >> test_connection.bat

REM Criar script para verificar instalação
echo @echo off > check_install.bat
echo echo 🔍 Verificando instalação... >> check_install.bat
echo cd backend >> check_install.bat
echo call venv\Scripts\activate.bat >> check_install.bat
echo echo Versão do Python: >> check_install.bat
echo python --version >> check_install.bat
echo echo. >> check_install.bat
echo echo Pacotes instalados: >> check_install.bat
echo pip list ^| findstr "fastapi uvicorn pandas numpy" >> check_install.bat
echo echo. >> check_install.bat
echo echo Testando imports: >> check_install.bat
echo python -c "import fastapi, uvicorn, pandas, numpy; print('✅ Imports OK')" >> check_install.bat
echo pause >> check_install.bat

echo.
echo 🎉 Configuração concluída!
echo.
echo 📋 Scripts criados:
echo   - run_backend.bat     - Executar backend local
echo   - run_worker.bat      - Executar worker Celery
echo   - run_beat.bat        - Executar beat Celery  
echo   - seed_database.bat   - Popular banco de dados
echo   - test_connection.bat - Testar conexão com VM
echo   - check_install.bat   - Verificar instalação
echo.
echo 📝 Próximos passos:
echo 1. Configure o IP da VM no arquivo backend\.env
echo 2. Execute check_install.bat para verificar instalação
echo 3. Execute test_connection.bat para testar conexão
echo 4. Execute seed_database.bat para popular o banco
echo 5. Execute run_backend.bat para iniciar o servidor
echo.
echo 🌐 Acesso após inicialização:
echo   - API: http://localhost:8000
echo   - Docs: http://localhost:8000/api/v1/docs
echo.
echo ⚠️  Lembre-se de configurar o IP da VM em backend\.env
echo.
echo 🔧 Se houver problemas:
echo   - Execute check_install.bat para diagnóstico
echo   - Verifique se Python 3.9-3.11 está instalado
echo   - Considere instalar Visual C++ Build Tools se necessário
pause 