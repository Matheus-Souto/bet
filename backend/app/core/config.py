from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    # Database (pode ser local ou VM)
    DATABASE_URL: str = "postgresql://bet_user:bet_password@localhost:5432/bet_db"
    
    # Redis (pode ser local ou VM)
    REDIS_URL: str = "redis://localhost:6379"
    
    # API Keys
    FOOTBALL_API_KEY: Optional[str] = None
    RAPID_API_KEY: Optional[str] = None
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # External APIs
    FOOTBALL_DATA_API_URL: str = "https://api.football-data.org/v4"
    API_FOOTBALL_URL: str = "https://v3.football.api-sports.io"
    
    # Rate Limiting
    RATE_LIMIT_REQUESTS: int = 100
    RATE_LIMIT_WINDOW: int = 3600  # 1 hora
    
    # Scraping
    SELENIUM_HEADLESS: bool = True
    REQUEST_TIMEOUT: int = 30
    
    # Celery (usa Redis)
    CELERY_BROKER_URL: Optional[str] = None
    CELERY_RESULT_BACKEND: Optional[str] = None
    
    # Development flags
    LOCAL_DEVELOPMENT: bool = False  # True quando rodando localmente
    VM_IP: Optional[str] = None      # IP da VM para desenvolvimento
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        # Auto-configurar Celery URLs se não especificadas
        if not self.CELERY_BROKER_URL:
            self.CELERY_BROKER_URL = self.REDIS_URL
        if not self.CELERY_RESULT_BACKEND:
            self.CELERY_RESULT_BACKEND = self.REDIS_URL
            
        # Detectar desenvolvimento local baseado na DATABASE_URL
        if "localhost" not in self.DATABASE_URL and "127.0.0.1" not in self.DATABASE_URL:
            self.LOCAL_DEVELOPMENT = True
            # Extrair IP da VM da DATABASE_URL
            try:
                import re
                match = re.search(r'@(\d+\.\d+\.\d+\.\d+):', self.DATABASE_URL)
                if match:
                    self.VM_IP = match.group(1)
            except:
                pass
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        
    def get_database_url_for_alembic(self) -> str:
        """URL do banco para Alembic (migrations)"""
        return self.DATABASE_URL
        
    def is_development(self) -> bool:
        """Verifica se está em ambiente de desenvolvimento"""
        return self.ENVIRONMENT.lower() in ["development", "dev", "local"]
        
    def is_local_development(self) -> bool:
        """Verifica se está rodando desenvolvimento local com VM"""
        return self.LOCAL_DEVELOPMENT
        
    def get_external_url(self, port: int = 8000) -> str:
        """Gera URL externa para acesso à API"""
        if self.LOCAL_DEVELOPMENT and self.VM_IP:
            return f"http://localhost:{port}"
        return f"http://localhost:{port}"

settings = Settings() 