@echo off 
echo 🔄 Iniciando worker Celery... 
cd backend 
call venv\Scripts\activate.bat 
celery -A app.worker worker --loglevel=info 
pause 
