"""Scheduled ingestion job to populate market_price_trends table from Agmarknet."""

import os
import sys
from datetime import datetime, timezone

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.database import SessionLocal, Base, engine
from app.models.economics import MarketPriceTrend
from app.services.agmarknet_fetcher import agmarknet_fetcher


def ingest_agmarknet_prices():
    print("Ingesting Agmarknet Mandi Prices into market_price_trends...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        records = agmarknet_fetcher.fetch_live_mandi_prices()
        count = 0

        for r in records:
            # Check if record exists for same commodity, district, and mandi
            existing = (
                db.query(MarketPriceTrend)
                .filter(
                    MarketPriceTrend.commodity_name == r["commodity_name"],
                    MarketPriceTrend.district == r["district"],
                    MarketPriceTrend.mandi_name == r["mandi_name"],
                )
                .first()
            )

            if existing:
                existing.modal_price = r["modal_price"]
                existing.min_price = r["min_price"]
                existing.max_price = r["max_price"]
                existing.price_unit = r["price_unit"]
                existing.official_source = r["official_source"]
                existing.fetched_at = r["fetched_at"]
            else:
                new_entry = MarketPriceTrend(
                    commodity_name=r["commodity_name"],
                    sector=r["sector"],
                    state=r["state"],
                    district=r["district"],
                    mandi_name=r["mandi_name"],
                    modal_price=r["modal_price"],
                    min_price=r["min_price"],
                    max_price=r["max_price"],
                    price_unit=r["price_unit"],
                    official_source=r["official_source"],
                    fetched_at=r["fetched_at"],
                )
                db.add(new_entry)
            count += 1

        db.commit()
        print(f"Successfully ingested/updated {count} mandi price records.")
    except Exception as e:
        db.rollback()
        print(f"Error ingesting mandi prices: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    ingest_agmarknet_prices()
