@echo off 
echo 🌱 Populando banco de dados... 
cd backend 
call venv\Scripts\activate.bat 
cd .. 
python scripts\seed_data.py 
pause 
