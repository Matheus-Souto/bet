@echo off 
echo 🔍 Verificando instalação... 
cd backend 
call venv\Scripts\activate.bat 
echo Versão do Python: 
python --version 
echo. 
echo Pacotes instalados: 
pip list | findstr "fastapi uvicorn pandas numpy" 
echo. 
echo Testando imports: 
python -c "import fastapi, uvicorn, pandas, numpy; print('✅ Imports OK')" 
pause 
