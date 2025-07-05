from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, date
from app.core.database import get_db
from app.models.match import Match
from app.schemas.match import MatchCreate, MatchResponse, MatchUpdate

router = APIRouter()

@router.get("/", response_model=List[MatchResponse])
async def get_matches(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(10, ge=1, le=100, description="Limite de registros"),
    date_from: Optional[date] = Query(None, description="Data inicial (YYYY-MM-DD)"),
    date_to: Optional[date] = Query(None, description="Data final (YYYY-MM-DD)"),
    status: Optional[str] = Query(None, description="Status da partida"),
    league: Optional[str] = Query(None, description="Filtrar por liga"),
    db: Session = Depends(get_db)
):
    """Listar partidas com filtros opcionais"""
    query = db.query(Match)
    
    if date_from:
        query = query.filter(Match.match_date >= date_from)
    
    if date_to:
        query = query.filter(Match.match_date <= date_to)
    
    if status:
        query = query.filter(Match.status == status)
    
    if league:
        query = query.filter(Match.league_name.ilike(f"%{league}%"))
    
    matches = query.order_by(Match.match_date.desc()).offset(skip).limit(limit).all()
    return matches

@router.get("/{match_id}", response_model=MatchResponse)
async def get_match(match_id: int, db: Session = Depends(get_db)):
    """Buscar uma partida específica por ID"""
    match = db.query(Match).filter(Match.id == match_id).first()
    if not match:
        raise HTTPException(status_code=404, detail="Partida não encontrada")
    return match

@router.get("/today", response_model=List[MatchResponse])
async def get_today_matches(db: Session = Depends(get_db)):
    """Buscar partidas de hoje"""
    today = date.today()
    matches = db.query(Match).filter(
        Match.match_date >= today,
        Match.match_date < today.replace(day=today.day + 1)
    ).all()
    return matches

@router.post("/", response_model=MatchResponse)
async def create_match(match: MatchCreate, db: Session = Depends(get_db)):
    """Criar uma nova partida"""
    db_match = Match(**match.dict())
    db.add(db_match)
    db.commit()
    db.refresh(db_match)
    return db_match

@router.put("/{match_id}", response_model=MatchResponse)
async def update_match(
    match_id: int, 
    match_update: MatchUpdate, 
    db: Session = Depends(get_db)
):
    """Atualizar uma partida existente"""
    db_match = db.query(Match).filter(Match.id == match_id).first()
    if not db_match:
        raise HTTPException(status_code=404, detail="Partida não encontrada")
    
    for field, value in match_update.dict(exclude_unset=True).items():
        setattr(db_match, field, value)
    
    db.commit()
    db.refresh(db_match)
    return db_match 