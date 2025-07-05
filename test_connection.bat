@echo off 
echo 🔍 Testando conexão com VM... 
cd backend 
call venv\Scripts\activate.bat 
python -c "from app.core.database import engine; conn = engine.connect(); print('✅ Conexão OK!'); conn.close()" 
if %errorlevel% neq 0 ( 
    echo ❌ Erro de conexão. Verifique se a VM está rodando e o IP está correto no .env 
) 
pause 
