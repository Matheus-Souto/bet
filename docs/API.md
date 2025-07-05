# 📡 Documentação da API - Bet Analytics

## Visão Geral

A API do Bet Analytics fornece acesso a dados de times, partidas e análises estatísticas para apoiar decisões em apostas esportivas.

**URL Base**: `http://localhost:8000/api/v1`

## Autenticação

Atualmente, a API não requer autenticação. Em produção, será implementado sistema de API keys.

## Endpoints Principais

### 📊 Times

#### Listar Times

```http
GET /api/v1/teams
```

**Parâmetros de Query:**

- `skip` (int): Número de registros para pular (padrão: 0)
- `limit` (int): Limite de registros (padrão: 10, máx: 100)
- `country` (string): Filtrar por país
- `league` (string): Filtrar por liga

**Resposta:**

```json
[
  {
    "id": 1,
    "name": "Real Madrid",
    "short_name": "RMA",
    "country": "Spain",
    "league_name": "La Liga",
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
    "away_wins": 12,
    "is_active": true
  }
]
```

#### Buscar Time Específico

```http
GET /api/v1/teams/{team_id}
```

#### Criar Time

```http
POST /api/v1/teams
```

**Body:**

```json
{
  "name": "Barcelona",
  "short_name": "BAR",
  "country": "Spain",
  "league_name": "La Liga",
  "founded": 1899
}
```

### ⚽ Partidas

#### Listar Partidas

```http
GET /api/v1/matches
```

**Parâmetros de Query:**

- `skip` (int): Paginação
- `limit` (int): Limite
- `date_from` (date): Data inicial (YYYY-MM-DD)
- `date_to` (date): Data final (YYYY-MM-DD)
- `status` (string): Status da partida
- `league` (string): Filtrar por liga

**Resposta:**

```json
[
  {
    "id": 1,
    "home_team_id": 1,
    "away_team_id": 2,
    "match_date": "2024-01-20T18:00:00Z",
    "league_name": "La Liga",
    "season": "2023-24",
    "status": "scheduled",
    "home_goals": null,
    "away_goals": null,
    "home_odds": 1.85,
    "draw_odds": 3.4,
    "away_odds": 4.2,
    "over_2_5_odds": 1.7,
    "btts_yes_odds": 1.65
  }
]
```

#### Partidas de Hoje

```http
GET /api/v1/matches/today
```

#### Buscar Partida Específica

```http
GET /api/v1/matches/{match_id}
```

### 📈 Análises

#### Analisar Partida

```http
GET /api/v1/analysis/match/{match_id}
```

**Resposta:**

```json
{
  "match_id": 1,
  "home_team": {
    "name": "Real Madrid",
    "avg_goals_scored": 2.24,
    "avg_goals_conceded": 0.84,
    "win_percentage": 0.737,
    "home_wins": 16,
    "home_draws": 3,
    "home_losses": 1
  },
  "away_team": {
    "name": "Barcelona",
    "avg_goals_scored": 2.1,
    "avg_goals_conceded": 1.2,
    "win_percentage": 0.68,
    "away_wins": 14,
    "away_draws": 4,
    "away_losses": 2
  },
  "predictions": {
    "total_goals_prediction": 4.34,
    "btts_probability": 0.75,
    "home_win_probability": 0.45,
    "draw_probability": 0.25,
    "away_win_probability": 0.3
  },
  "trends": [
    {
      "type": "over_2_5",
      "confidence": 0.85,
      "description": "Tendência para mais de 2.5 gols"
    }
  ]
}
```

#### Buscar Trends Gerais

```http
GET /api/v1/analysis/trends
```

**Parâmetros:**

- `league` (string): Filtrar por liga
- `trend_type` (string): Tipo de trend

**Resposta:**

```json
[
  {
    "type": "over_2_5",
    "description": "Jogos com mais de 2.5 gols",
    "confidence": 0.75,
    "matches_count": 15,
    "success_rate": 0.8
  }
]
```

#### Forma Recente do Time

```http
GET /api/v1/analysis/team/{team_id}/form
```

**Resposta:**

```json
{
  "team_id": 1,
  "team_name": "Real Madrid",
  "recent_form": [
    {
      "match_id": 101,
      "date": "2024-01-15T18:00:00Z",
      "result": "W",
      "goals_for": 2,
      "goals_against": 1,
      "opponent": "Sevilla"
    }
  ],
  "form_string": "WWLWD"
}
```

## Códigos de Status

- `200` - Sucesso
- `201` - Criado
- `400` - Erro de validação
- `404` - Recurso não encontrado
- `422` - Erro de processamento
- `500` - Erro interno do servidor

## Limites de Taxa

- **Desenvolvimento**: Sem limite
- **Produção**: 1000 requests/hora por IP

## Tipos de Dados

### Status de Partida

- `scheduled` - Agendada
- `live` - Ao vivo
- `finished` - Finalizada
- `postponed` - Adiada
- `cancelled` - Cancelada

### Tipos de Trends

- `over_2_5` - Mais de 2.5 gols
- `under_2_5` - Menos de 2.5 gols
- `btts` - Ambos marcam
- `home_win` - Vitória em casa
- `away_win` - Vitória fora
- `draw` - Empate

## Exemplos de Uso

### Python

```python
import requests

# Buscar times
response = requests.get("http://localhost:8000/api/v1/teams")
teams = response.json()

# Analisar partida
response = requests.get("http://localhost:8000/api/v1/analysis/match/1")
analysis = response.json()
```

### JavaScript

```javascript
// Buscar partidas de hoje
fetch('http://localhost:8000/api/v1/matches/today')
  .then(response => response.json())
  .then(matches => console.log(matches));
```

### cURL

```bash
# Buscar trends
curl -X GET "http://localhost:8000/api/v1/analysis/trends?league=La%20Liga"
```

## Documentação Interativa

Acesse `http://localhost:8000/api/v1/docs` para a documentação interativa Swagger.
