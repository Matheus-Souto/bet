from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime

class MatchBase(BaseModel):
    home_team_id: int
    away_team_id: int
    league_id: Optional[int] = None
    league_name: Optional[str] = Field(None, max_length=100)
    season: Optional[str] = Field(None, max_length=10)
    round: Optional[str] = Field(None, max_length=50)
    match_date: datetime
    status: str = Field("scheduled", max_length=20)

class MatchCreate(MatchBase):
    external_id: Optional[str] = Field(None, max_length=50)

class MatchUpdate(BaseModel):
    league_id: Optional[int] = None
    league_name: Optional[str] = Field(None, max_length=100)
    season: Optional[str] = Field(None, max_length=10)
    round: Optional[str] = Field(None, max_length=50)
    match_date: Optional[datetime] = None
    status: Optional[str] = Field(None, max_length=20)
    
    # Resultado
    home_goals: Optional[int] = Field(None, ge=0)
    away_goals: Optional[int] = Field(None, ge=0)
    winner: Optional[str] = Field(None, max_length=10)
    
    # Odds
    home_odds: Optional[float] = Field(None, gt=0)
    draw_odds: Optional[float] = Field(None, gt=0)
    away_odds: Optional[float] = Field(None, gt=0)
    over_2_5_odds: Optional[float] = Field(None, gt=0)
    under_2_5_odds: Optional[float] = Field(None, gt=0)
    btts_yes_odds: Optional[float] = Field(None, gt=0)
    btts_no_odds: Optional[float] = Field(None, gt=0)
    
    # Estatísticas
    statistics: Optional[Dict[str, Any]] = None
    
    # Análise
    prediction_confidence: Optional[float] = Field(None, ge=0, le=1)
    predicted_result: Optional[str] = Field(None, max_length=20)
    analysis_notes: Optional[str] = None

class MatchResponse(MatchBase):
    id: int
    external_id: Optional[str]
    home_goals: Optional[int]
    away_goals: Optional[int]
    winner: Optional[str]
    total_goals: int
    both_teams_scored: bool
    
    # Odds
    home_odds: Optional[float]
    draw_odds: Optional[float]
    away_odds: Optional[float]
    over_2_5_odds: Optional[float]
    under_2_5_odds: Optional[float]
    btts_yes_odds: Optional[float]
    btts_no_odds: Optional[float]
    
    # Estatísticas
    statistics: Optional[Dict[str, Any]]
    
    # Análise
    prediction_confidence: Optional[float]
    predicted_result: Optional[str]
    analysis_notes: Optional[str]
    
    # Timestamps
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True 