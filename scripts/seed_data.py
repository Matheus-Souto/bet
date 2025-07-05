#!/usr/bin/env python3
"""
Script para popular o banco de dados com dados de exemplo
"""

import sys
import os
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

# Adicionar o diretório backend ao path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

from app.core.database import SessionLocal, engine, Base
from app.models.team import Team
from app.models.match import Match

def create_sample_teams(db: Session):
    """Criar times de exemplo"""
    teams_data = [
        {
            "name": "Real Madrid",
            "short_name": "RMA",
            "country": "Spain",
            "league_name": "La Liga",
            "founded": 1902,
            "games_played": 38,
            "wins": 28,
            "draws": 6,
            "losses": 4,
            "goals_for": 85,
            "goals_against": 32,
            "avg_goals_scored": 2.24,
            "avg_goals_conceded": 0.84,
            "win_percentage": 0.737,
            "home_wins": 16,
            "home_draws": 3,
            "home_losses": 1,
            "away_wins": 12,
            "away_draws": 3,
            "away_losses": 3
        },
        {
            "name": "Barcelona",
            "short_name": "BAR",
            "country": "Spain",
            "league_name": "La Liga",
            "founded": 1899,
            "games_played": 38,
            "wins": 26,
            "draws": 8,
            "losses": 4,
            "goals_for": 80,
            "goals_against": 45,
            "avg_goals_scored": 2.1,
            "avg_goals_conceded": 1.2,
            "win_percentage": 0.68,
            "home_wins": 15,
            "home_draws": 4,
            "home_losses": 0,
            "away_wins": 11,
            "away_draws": 4,
            "away_losses": 4
        },
        {
            "name": "Manchester City",
            "short_name": "MCI",
            "country": "England",
            "league_name": "Premier League",
            "founded": 1880,
            "games_played": 38,
            "wins": 32,
            "draws": 3,
            "losses": 3,
            "goals_for": 99,
            "goals_against": 31,
            "avg_goals_scored": 2.61,
            "avg_goals_conceded": 0.82,
            "win_percentage": 0.842,
            "home_wins": 17,
            "home_draws": 1,
            "home_losses": 1,
            "away_wins": 15,
            "away_draws": 2,
            "away_losses": 2
        },
        {
            "name": "Liverpool",
            "short_name": "LIV",
            "country": "England",
            "league_name": "Premier League",
            "founded": 1892,
            "games_played": 38,
            "wins": 19,
            "draws": 10,
            "losses": 9,
            "goals_for": 75,
            "goals_against": 47,
            "avg_goals_scored": 1.97,
            "avg_goals_conceded": 1.24,
            "win_percentage": 0.5,
            "home_wins": 12,
            "home_draws": 4,
            "home_losses": 3,
            "away_wins": 7,
            "away_draws": 6,
            "away_losses": 6
        },
        {
            "name": "Bayern Munich",
            "short_name": "BAY",
            "country": "Germany",
            "league_name": "Bundesliga",
            "founded": 1900,
            "games_played": 34,
            "wins": 24,
            "draws": 6,
            "losses": 4,
            "goals_for": 92,
            "goals_against": 35,
            "avg_goals_scored": 2.7,
            "avg_goals_conceded": 1.03,
            "win_percentage": 0.706,
            "home_wins": 14,
            "home_draws": 2,
            "home_losses": 1,
            "away_wins": 10,
            "away_draws": 4,
            "away_losses": 3
        },
        {
            "name": "Paris Saint-Germain",
            "short_name": "PSG",
            "country": "France",
            "league_name": "Ligue 1",
            "founded": 1970,
            "games_played": 38,
            "wins": 29,
            "draws": 6,
            "losses": 3,
            "goals_for": 89,
            "goals_against": 26,
            "avg_goals_scored": 2.34,
            "avg_goals_conceded": 0.68,
            "win_percentage": 0.763,
            "home_wins": 16,
            "home_draws": 2,
            "home_losses": 1,
            "away_wins": 13,
            "away_draws": 4,
            "away_losses": 2
        }
    ]
    
    created_teams = []
    for team_data in teams_data:
        # Verificar se o time já existe
        existing_team = db.query(Team).filter(Team.name == team_data["name"]).first()
        if not existing_team:
            team = Team(**team_data)
            db.add(team)
            created_teams.append(team)
    
    db.commit()
    
    # Refresh para obter IDs
    for team in created_teams:
        db.refresh(team)
    
    print(f"Criados {len(created_teams)} times de exemplo")
    return created_teams

def create_sample_matches(db: Session):
    """Criar partidas de exemplo"""
    # Buscar times
    teams = db.query(Team).limit(6).all()
    
    if len(teams) < 4:
        print("Não há times suficientes para criar partidas")
        return
    
    # Criar partidas futuras
    future_matches = [
        {
            "home_team_id": teams[0].id,  # Real Madrid
            "away_team_id": teams[1].id,  # Barcelona
            "league_name": "La Liga",
            "season": "2023-24",
            "round": "Matchday 20",
            "match_date": datetime.now() + timedelta(days=2),
            "status": "scheduled",
            "home_odds": 1.85,
            "draw_odds": 3.40,
            "away_odds": 4.20,
            "over_2_5_odds": 1.70,
            "under_2_5_odds": 2.10,
            "btts_yes_odds": 1.65,
            "btts_no_odds": 2.25
        },
        {
            "home_team_id": teams[2].id,  # Manchester City
            "away_team_id": teams[3].id,  # Liverpool
            "league_name": "Premier League",
            "season": "2023-24",
            "round": "Matchday 21",
            "match_date": datetime.now() + timedelta(days=3),
            "status": "scheduled",
            "home_odds": 1.95,
            "draw_odds": 3.60,
            "away_odds": 3.80,
            "over_2_5_odds": 1.50,
            "under_2_5_odds": 2.60,
            "btts_yes_odds": 1.55,
            "btts_no_odds": 2.45
        }
    ]
    
    # Criar partidas passadas
    past_matches = [
        {
            "home_team_id": teams[0].id,  # Real Madrid
            "away_team_id": teams[2].id,  # Manchester City
            "league_name": "Champions League",
            "season": "2023-24",
            "round": "Quarterfinals",
            "match_date": datetime.now() - timedelta(days=7),
            "status": "finished",
            "home_goals": 2,
            "away_goals": 1,
            "winner": "home",
            "total_goals": 3,
            "both_teams_scored": True
        },
        {
            "home_team_id": teams[1].id,  # Barcelona
            "away_team_id": teams[3].id,  # Liverpool
            "league_name": "Champions League",
            "season": "2023-24",
            "round": "Quarterfinals",
            "match_date": datetime.now() - timedelta(days=5),
            "status": "finished",
            "home_goals": 1,
            "away_goals": 3,
            "winner": "away",
            "total_goals": 4,
            "both_teams_scored": True
        }
    ]
    
    all_matches = future_matches + past_matches
    created_matches = []
    
    for match_data in all_matches:
        match = Match(**match_data)
        db.add(match)
        created_matches.append(match)
    
    db.commit()
    
    print(f"Criadas {len(created_matches)} partidas de exemplo")
    return created_matches

def main():
    """Função principal"""
    print("🌱 Iniciando seed do banco de dados...")
    
    # Criar tabelas
    Base.metadata.create_all(bind=engine)
    
    # Criar sessão
    db = SessionLocal()
    
    try:
        # Criar dados de exemplo
        teams = create_sample_teams(db)
        matches = create_sample_matches(db)
        
        print("✅ Seed concluído com sucesso!")
        print(f"📊 Resumo:")
        print(f"   - Times criados: {len(teams)}")
        print(f"   - Partidas criadas: {len(matches)}")
        
    except Exception as e:
        print(f"❌ Erro durante o seed: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main() 