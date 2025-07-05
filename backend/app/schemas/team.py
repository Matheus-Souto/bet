from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class TeamBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    short_name: Optional[str] = Field(None, max_length=10)
    logo_url: Optional[str] = Field(None, max_length=255)
    league_id: Optional[int] = None
    league_name: Optional[str] = Field(None, max_length=100)
    country: Optional[str] = Field(None, max_length=50)
    founded: Optional[int] = Field(None, ge=1800, le=2100)

class TeamCreate(TeamBase):
    pass

class TeamUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    short_name: Optional[str] = Field(None, max_length=10)
    logo_url: Optional[str] = Field(None, max_length=255)
    league_id: Optional[int] = None
    league_name: Optional[str] = Field(None, max_length=100)
    country: Optional[str] = Field(None, max_length=50)
    founded: Optional[int] = Field(None, ge=1800, le=2100)
    
    # Estatísticas
    games_played: Optional[int] = Field(None, ge=0)
    wins: Optional[int] = Field(None, ge=0)
    draws: Optional[int] = Field(None, ge=0)
    losses: Optional[int] = Field(None, ge=0)
    goals_for: Optional[int] = Field(None, ge=0)
    goals_against: Optional[int] = Field(None, ge=0)

class TeamResponse(TeamBase):
    id: int
    games_played: int
    wins: int
    draws: int
    losses: int
    goals_for: int
    goals_against: int
    avg_goals_scored: float
    avg_goals_conceded: float
    win_percentage: float
    home_wins: int
    home_draws: int
    home_losses: int
    away_wins: int
    away_draws: int
    away_losses: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True 