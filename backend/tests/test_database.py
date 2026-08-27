from sqlalchemy import inspect
from app.core.database import Base, engine
import app.models  # Imports all models


def test_create_all_database_tables():
    Base.metadata.create_all(bind=engine)
    inspector = inspect(engine)
    tables = inspector.get_table_names()

    expected_tables = [
        "users",
        "farmer_profiles",
        "otp_records",
        "agricultural_plots",
        "livestock_units",
        "poultry_units",
        "aquaculture_units",
        "crop_records",
        "livestock_records",
        "poultry_records",
        "aquaculture_records",
        "fertilizer_price_index",
        "fuel_price_index",
        "feed_price_index",
        "market_price_trends",
        "official_fertilizer_mrp",
        "verified_produce_stock",
        "blockchain_ledger_blocks",
        "historical_climate_data",
        "suggestion_audit_logs",
        "veterinary_services",
        "geo_region_language_maps",
    ]

    for table in expected_tables:
        assert table in tables, f"Expected table {table} was not created in database schema."
