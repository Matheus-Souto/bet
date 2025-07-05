from celery import Celery
from app.core.config import settings

# Configurar Celery
celery_app = Celery(
    "bet_analytics",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["app.tasks"]
)

# Configurações
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutos
    task_soft_time_limit=240,  # 4 minutos
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=1000,
)

# Agendamento de tarefas
celery_app.conf.beat_schedule = {
    "collect-daily-matches": {
        "task": "app.tasks.collect_daily_matches",
        "schedule": 3600.0,  # A cada hora
    },
    "update-team-stats": {
        "task": "app.tasks.update_team_statistics",
        "schedule": 7200.0,  # A cada 2 horas
    },
    "analyze-upcoming-matches": {
        "task": "app.tasks.analyze_upcoming_matches",
        "schedule": 1800.0,  # A cada 30 minutos
    },
}

if __name__ == "__main__":
    celery_app.start() 