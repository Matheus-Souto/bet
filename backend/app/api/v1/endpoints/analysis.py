from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.models.match import Match
from app.models.team import Team
from app.schemas.analysis import AnalysisResponse, TrendResponse

router = APIRouter()

@router.get("/match/{match_id}", response_model=AnalysisResponse)
async def analyze_match(match_id: int, db: Session = Depends(get_db)):
    """Analisar uma partida específica"""
    match = db.query(Match).filter(Match.id == match_id).first()
    if not match:
        raise HTTPException(status_code=404, detail="Partida não encontrada")
    
    # Buscar estatísticas dos times
    home_team = db.query(Team).filter(Team.id == match.home_team_id).first()
    away_team = db.query(Team).filter(Team.id == match.away_team_id).first()
    
    # Análise básica
    analysis = {
        "match_id": match_id,
        "home_team": {
            "name": home_team.name,
            "avg_goals_scored": home_team.avg_goals_scored,
            "avg_goals_conceded": home_team.avg_goals_conceded,
            "win_percentage": home_team.win_percentage,
            "home_wins": home_team.home_wins,
            "home_draws": home_team.home_draws,
            "home_losses": home_team.home_losses
        },
        "away_team": {
            "name": away_team.name,
            "avg_goals_scored": away_team.avg_goals_scored,
            "avg_goals_conceded": away_team.avg_goals_conceded,
            "win_percentage": away_team.win_percentage,
            "away_wins": away_team.away_wins,
            "away_draws": away_team.away_draws,
            "away_losses": away_team.away_losses
        },
        "predictions": {
            "total_goals_prediction": home_team.avg_goals_scored + away_team.avg_goals_scored,
            "btts_probability": 0.5,  # Placeholder
            "home_win_probability": 0.33,  # Placeholder
            "draw_probability": 0.33,  # Placeholder
            "away_win_probability": 0.33  # Placeholder
        },
        "trends": [
            {
                "type": "over_2_5",
                "confidence": 0.6,
                "description": "Tendência para mais de 2.5 gols"
            }
        ]
    }
    
    return analysis

@router.get("/trends", response_model=List[TrendResponse])
async def get_trends(
    league: Optional[str] = Query(None, description="Filtrar por liga"),
    trend_type: Optional[str] = Query(None, description="Tipo de trend"),
    db: Session = Depends(get_db)
):
    """Buscar trends gerais"""
    # Implementação básica de trends
    trends = [
        {
            "type": "over_2_5",
            "description": "Jogos com mais de 2.5 gols",
            "confidence": 0.75,
            "matches_count": 15,
            "success_rate": 0.8
        },
        {
            "type": "btts",
            "description": "Ambos os times marcam",
            "confidence": 0.65,
            "matches_count": 12,
            "success_rate": 0.7
        }
    ]
    
    return trends

@router.get("/team/{team_id}/form")
async def get_team_form(team_id: int, db: Session = Depends(get_db)):
    """Buscar forma recente de um time"""
    team = db.query(Team).filter(Team.id == team_id).first()
    if not team:
        raise HTTPException(status_code=404, detail="Time não encontrado")
    
    # Buscar últimos jogos
    recent_matches = db.query(Match).filter(
        (Match.home_team_id == team_id) | (Match.away_team_id == team_id),
        Match.status == "finished"
    ).order_by(Match.match_date.desc()).limit(5).all()
    
    form = []
    for match in recent_matches:
        if match.home_team_id == team_id:
            result = "W" if match.winner == "home" else "D" if match.winner == "draw" else "L"
            goals_for = match.home_goals
            goals_against = match.away_goals
        else:
            result = "W" if match.winner == "away" else "D" if match.winner == "draw" else "L"
            goals_for = match.away_goals
            goals_against = match.home_goals
        
        form.append({
            "match_id": match.id,
            "date": match.match_date,
            "result": result,
            "goals_for": goals_for,
            "goals_against": goals_against,
            "opponent": match.away_team.name if match.home_team_id == team_id else match.home_team.name
        })
    
    return {
        "team_id": team_id,
        "team_name": team.name,
        "recent_form": form,
        "form_string": "".join([f["result"] for f in form])
    } 