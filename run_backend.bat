@echo off 
echo 🚀 Iniciando backend local... 
cd backend 
call venv\Scripts\activate.bat 
echo ✅ Ambiente ativado. Iniciando servidor... 
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 
pause 
