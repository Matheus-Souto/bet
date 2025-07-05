@echo off
REM Script para configurar desenvolvimento local no Windows
REM Execute este script na máquina Windows

echo 🚀 Configurando desenvolvimento local no Windows...
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python não encontrado. Instale Python 3.11+ primeiro.
    echo Baixe em: https://www.python.org/downloads/
    pause
    exit /b 1
) else (
    echo ✅ Python encontrado
)

REM Verificar se pip está instalado
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip não encontrado
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

REM Criar ambiente virtual (opcional mas recomendado)
if not exist "venv" (
    echo 📦 Criando ambiente virtual...
    python -m venv venv
    echo ✅ Ambiente virtual criado
) else (
    echo ✅ Ambiente virtual já existe
)

REM Ativar ambiente virtual
echo 🔄 Ativando ambiente virtual...
call venv\Scripts\activate.bat

REM Atualizar pip
echo 📦 Atualizando pip...
python -m pip install --upgrade pip

REM Instalar dependências
echo 📦 Instalando dependências...
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo ❌ Erro ao instalar dependências
    pause
    exit /b 1
) else (
    echo ✅ Dependências instaladas com sucesso
)

REM Voltar ao diretório raiz
cd ..

REM Configurar arquivo .env
if not exist "backend\.env" (
    if exist "backend\.env.local" (
        echo 📝 Copiando configuração local...
        copy "backend\.env.local" "backend\.env"
    ) else (
        echo 📝 Criando arquivo .env básico...
        echo # Configuração Local - Substitua VM_IP_ADDRESS pelo IP da VM > backend\.env
        echo DATABASE_URL=postgresql://bet_user:bet_password@VM_IP_ADDRESS:5432/bet_db >> backend\.env
        echo REDIS_URL=redis://VM_IP_ADDRESS:6379 >> backend\.env
        echo CELERY_BROKER_URL=redis://VM_IP_ADDRESS:6379 >> backend\.env
        echo CELERY_RESULT_BACKEND=redis://VM_IP_ADDRESS:6379 >> backend\.env
        echo SECRET_KEY=minha_chave_secreta_local >> backend\.env
        echo DEBUG=true >> backend\.env
        echo ENVIRONMENT=development >> backend\.env
    )
    echo ⚠️  IMPORTANTE: Edite o arquivo backend\.env e substitua VM_IP_ADDRESS pelo IP real da VM
) else (
    echo ✅ Arquivo .env já existe
)

REM Criar script para executar o backend
echo @echo off > run_backend.bat
echo echo 🚀 Iniciando backend local... >> run_backend.bat
echo cd backend >> run_backend.bat
echo call venv\Scripts\activate.bat >> run_backend.bat
echo uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 >> run_backend.bat

REM Criar script para executar worker
echo @echo off > run_worker.bat
echo echo 🔄 Iniciando worker Celery... >> run_worker.bat
echo cd backend >> run_worker.bat
echo call venv\Scripts\activate.bat >> run_worker.bat
echo celery -A app.worker worker --loglevel=info >> run_worker.bat

REM Criar script para executar beat
echo @echo off > run_beat.bat
echo echo ⏰ Iniciando beat Celery... >> run_beat.bat
echo cd backend >> run_beat.bat
echo call venv\Scripts\activate.bat >> run_beat.bat
echo celery -A app.worker beat --loglevel=info >> run_beat.bat

REM Criar script para popular banco
echo @echo off > seed_database.bat
echo echo 🌱 Populando banco de dados... >> seed_database.bat
echo cd backend >> seed_database.bat
echo call venv\Scripts\activate.bat >> seed_database.bat
echo cd .. >> seed_database.bat
echo python scripts\seed_data.py >> seed_database.bat

REM Criar script para testar conexão
echo @echo off > test_connection.bat
echo echo 🔍 Testando conexão com VM... >> test_connection.bat
echo cd backend >> test_connection.bat
echo call venv\Scripts\activate.bat >> test_connection.bat
echo python -c "from app.core.database import engine; conn = engine.connect(); print('✅ Conexão OK!'); conn.close()" >> test_connection.bat

echo.
echo 🎉 Configuração concluída!
echo.
echo 📋 Scripts criados:
echo   - run_backend.bat    - Executar backend local
echo   - run_worker.bat     - Executar worker Celery
echo   - run_beat.bat       - Executar beat Celery  
echo   - seed_database.bat  - Popular banco de dados
echo   - test_connection.bat - Testar conexão com VM
echo.
echo 📝 Próximos passos:
echo 1. Configure o IP da VM no arquivo backend\.env
echo 2. Execute test_connection.bat para testar conexão
echo 3. Execute seed_database.bat para popular o banco
echo 4. Execute run_backend.bat para iniciar o servidor
echo.
echo 🌐 Acesso:
echo   - API: http://localhost:8000
echo   - Docs: http://localhost:8000/api/v1/docs
echo.
echo ⚠️  Lembre-se de configurar o IP da VM em backend\.env
pause 