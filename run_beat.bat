@echo off 
echo ⏰ Iniciando beat Celery... 
cd backend 
call venv\Scripts\activate.bat 
celery -A app.worker beat --loglevel=info 
pause 
