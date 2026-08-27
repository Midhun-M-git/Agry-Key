# Agry-Key

Net profit optimization platform for India's food producers — covers agriculture, livestock, poultry, dairy, and aquaculture under one roof.

## The problem

A farmer with 3 acres of land, 50 cows, and a fish pond has no single tool that tells them their combined net profit, which crop to switch to, or whether the fertilizer dealer is overcharging them. Government data exists but is scattered across a dozen portals, none of which speak Tamil or Marathi.

## What this does

Pulls verified data from official sources (Agmarknet, IMD, NDDB, NFDB, PPAC, mFMS), runs it through a triple-agent AI pipeline (data checker → advisory → verifier), and delivers spoken financial advice in the farmer's own regional dialect. No typing, no menus, no internet literacy required.

Key capabilities:
- Per-sector and combined portfolio net profit calculation
- Cross-sector cost savings (cow dung → fertilizer, hen droppings → fish feed)
- Alternative crop/activity ranking by projected net return
- Blockchain-verified fertilizer MRP and produce stock (anti-fraud)
- Voice-first interface with regional language auto-detection via GPS

## Tech

| | |
|---|---|
| Backend | FastAPI, SQLAlchemy, Alembic |
| Auth | JWT + bcrypt |
| AI | Gemini Free API, AI4Bharat voice models |
| Forecasting | Prophet / LightGBM |
| Integrity | SHA-256 Merkle-hash chain |
| DB | SQLite (dev), PostgreSQL (prod) |
| Mobile | Flutter (planned) |

## Setup

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

Docs at `http://127.0.0.1:8000/docs`

## Where things stand

Phase 1 shipped — server foundation, CORS, rate limiting, auth utilities, health endpoint.

Full roadmap lives in [Issues](https://github.com/Midhun-M-git/Agry-Key/issues).

## License

MIT
