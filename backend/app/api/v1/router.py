from fastapi import APIRouter
from app.api.v1.endpoints import teams, matches, analysis

api_router = APIRouter()

# Incluir rotas
api_router.include_router(teams.router, prefix="/teams", tags=["teams"])
api_router.include_router(matches.router, prefix="/matches", tags=["matches"])
api_router.include_router(analysis.router, prefix="/analysis", tags=["analysis"]) 