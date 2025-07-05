from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class TeamAnalysis(BaseModel):
    name: str
    avg_goals_scored: float
    avg_goals_conceded: float
    win_percentage: float
    home_wins: int
    home_draws: int
    home_losses: int
    away_wins: int
    away_draws: int
    away_losses: int

class MatchPrediction(BaseModel):
    total_goals_prediction: float
    btts_probability: float
    home_win_probability: float
    draw_probability: float
    away_win_probability: float

class TrendItem(BaseModel):
    type: str
    confidence: float
    description: str

class AnalysisResponse(BaseModel):
    match_id: int
    home_team: TeamAnalysis
    away_team: TeamAnalysis
    predictions: MatchPrediction
    trends: List[TrendItem]

class TrendResponse(BaseModel):
    type: str
    description: str
    confidence: float
    matches_count: int
    success_rate: float

class FormItem(BaseModel):
    match_id: int
    date: datetime
    result: str
    goals_for: int
    goals_against: int
    opponent: str

class TeamFormResponse(BaseModel):
    team_id: int
    team_name: str
    recent_form: List[FormItem]
    form_string: str 