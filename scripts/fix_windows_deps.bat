@echo off
REM Script para resolver problemas específicos de dependências no Windows

echo 🔧 Resolvendo problemas de dependências no Windows...
echo.

REM Verificar se estamos no diretório correto
if not exist "backend" (
    echo ❌ Execute este script na raiz do projeto
    pause
    exit /b 1
)

cd backend

REM Verificar se ambiente virtual existe
if not exist "venv" (
    echo ❌ Ambiente virtual não encontrado. Execute setup_windows.bat primeiro
    pause
    exit /b 1
)

REM Ativar ambiente virtual
call venv\Scripts\activate.bat

echo 📦 Atualizando ferramentas de build...
python -m pip install --upgrade pip
python -m pip install --upgrade setuptools wheel

echo.
echo 🔍 Tentando diferentes estratégias de instalação...
echo.

REM Estratégia 1: Instalar apenas binários pré-compilados
echo 📦 Estratégia 1: Apenas binários pré-compilados...
pip install --only-binary=all fastapi uvicorn pydantic sqlalchemy psycopg2-binary redis httpx requests python-dotenv celery beautifulsoup4 selenium pydantic-settings pytest python-dateutil loguru

if %errorlevel% equ 0 (
    echo ✅ Sucesso com binários pré-compilados!
    goto test_install
)

REM Estratégia 2: Instalar NumPy/Pandas de fonte confiável
echo.
echo 📦 Estratégia 2: Instalando NumPy/Pandas específicos...
pip uninstall numpy pandas scikit-learn -y
pip install --upgrade --force-reinstall numpy pandas scikit-learn

if %errorlevel% equ 0 (
    echo ✅ Sucesso com instalação forçada!
    goto test_install
)

REM Estratégia 3: Usar conda-forge ou sources alternativos
echo.
echo 📦 Estratégia 3: Usando índices alternativos...
pip install -i https://pypi.org/simple/ numpy pandas scikit-learn

if %errorlevel% equ 0 (
    echo ✅ Sucesso com índice alternativo!
    goto test_install
)

REM Estratégia 4: Instalação mínima
echo.
echo 📦 Estratégia 4: Instalação mínima (sem ML packages)...
pip install fastapi uvicorn[standard] pydantic sqlalchemy psycopg2-binary redis httpx requests python-dotenv pydantic-settings python-dateutil loguru

echo ⚠️  Instalação mínima concluída. Pacotes de ML (numpy, pandas, scikit-learn) não foram instalados.
echo Para resolver, você pode:
echo 1. Instalar Anaconda e usar conda em vez de pip
echo 2. Baixar wheels pré-compilados de https://www.lfd.uci.edu/~gohlke/pythonlibs/
echo 3. Instalar Visual Studio Build Tools

goto test_install

:test_install
echo.
echo 🧪 Testando instalação...

python -c "import fastapi; print('✅ FastAPI OK')" 2>nul
if %errorlevel% neq 0 echo ❌ FastAPI failed

python -c "import uvicorn; print('✅ Uvicorn OK')" 2>nul
if %errorlevel% neq 0 echo ❌ Uvicorn failed

python -c "import sqlalchemy; print('✅ SQLAlchemy OK')" 2>nul
if %errorlevel% neq 0 echo ❌ SQLAlchemy failed

python -c "import redis; print('✅ Redis OK')" 2>nul
if %errorlevel% neq 0 echo ❌ Redis failed

python -c "import numpy; print('✅ NumPy OK')" 2>nul
if %errorlevel% neq 0 echo ⚠️  NumPy not available

python -c "import pandas; print('✅ Pandas OK')" 2>nul
if %errorlevel% neq 0 echo ⚠️  Pandas not available

echo.
echo 📋 Instalação de dependências concluída!
echo.
echo Se alguns pacotes falharam, o sistema ainda pode funcionar.
echo Os pacotes essenciais são FastAPI, SQLAlchemy, Redis e Uvicorn.
echo.

cd ..
pause 