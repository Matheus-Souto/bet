from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.models.team import Team
from app.schemas.team import TeamCreate, TeamResponse, TeamUpdate

router = APIRouter()

@router.get("/", response_model=List[TeamResponse])
async def get_teams(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(10, ge=1, le=100, description="Limite de registros"),
    country: Optional[str] = Query(None, description="Filtrar por país"),
    league: Optional[str] = Query(None, description="Filtrar por liga"),
    db: Session = Depends(get_db)
):
    """Listar todos os times com filtros opcionais"""
    query = db.query(Team).filter(Team.is_active == True)
    
    if country:
        query = query.filter(Team.country.ilike(f"%{country}%"))
    
    if league:
        query = query.filter(Team.league_name.ilike(f"%{league}%"))
    
    teams = query.offset(skip).limit(limit).all()
    return teams

@router.get("/{team_id}", response_model=TeamResponse)
async def get_team(team_id: int, db: Session = Depends(get_db)):
    """Buscar um time específico por ID"""
    team = db.query(Team).filter(Team.id == team_id).first()
    if not team:
        raise HTTPException(status_code=404, detail="Time não encontrado")
    return team

@router.post("/", response_model=TeamResponse)
async def create_team(team: TeamCreate, db: Session = Depends(get_db)):
    """Criar um novo time"""
    db_team = Team(**team.dict())
    db.add(db_team)
    db.commit()
    db.refresh(db_team)
    return db_team

@router.put("/{team_id}", response_model=TeamResponse)
async def update_team(
    team_id: int, 
    team_update: TeamUpdate, 
    db: Session = Depends(get_db)
):
    """Atualizar um time existente"""
    db_team = db.query(Team).filter(Team.id == team_id).first()
    if not db_team:
        raise HTTPException(status_code=404, detail="Time não encontrado")
    
    for field, value in team_update.dict(exclude_unset=True).items():
        setattr(db_team, field, value)
    
    db.commit()
    db.refresh(db_team)
    return db_team

@router.delete("/{team_id}")
async def delete_team(team_id: int, db: Session = Depends(get_db)):
    """Deletar um time (soft delete)"""
    db_team = db.query(Team).filter(Team.id == team_id).first()
    if not db_team:
        raise HTTPException(status_code=404, detail="Time não encontrado")
    
    db_team.is_active = False
    db.commit()
    return {"message": "Time deletado com sucesso"} 