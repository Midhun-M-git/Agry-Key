"""Seed database with realistic multi-sector agricultural and blockchain data."""

import hashlib
import json
import os
import sys
from datetime import datetime, timezone, timedelta

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.database import SessionLocal, engine, Base
from app.core.security import get_password_hash
from app.models import (
    User,
    FarmerProfile,
    AgriculturalPlot,
    LivestockUnit,
    PoultryUnit,
    AquacultureUnit,
    BlockchainLedgerBlock,
    OfficialFertilizerMRP,
    VerifiedProduceStock,
    FuelPriceIndex,
    FertilizerPriceIndex,
    FeedPriceIndex,
    LabourRateIndex,
    TransportCostIndex,
    MarketPriceTrend,
    DistrictSoilSurvey,
    FarmerSoilHealthCard,
    Scheme,
    Product,
)
from app.models.user import UserRole


def calculate_sha256(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def seed_database():
    print("Creating all tables if they do not exist...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # 1. Genesis Block for Blockchain
        genesis_block = db.query(BlockchainLedgerBlock).filter_by(block_index=0).first()
        if not genesis_block:
            prev_hash = "0" * 64
            payload = json.dumps({"event": "GENESIS_BLOCK", "network": "AGRY_KEY_CONSORTIUM", "created_by": "SYSTEM"})
            block_hash = calculate_sha256(f"0{prev_hash}{payload}")
            genesis_block = BlockchainLedgerBlock(
                block_index=0,
                timestamp=datetime.now(timezone.utc),
                transaction_type="GENESIS",
                data_payload=payload,
                previous_hash=prev_hash,
                block_hash=block_hash,
            )
            db.add(genesis_block)
            print("Seeded Genesis Blockchain Block.")

        # 2. Sample Users
        farmer1 = db.query(User).filter_by(phone_number="+919876543210").first()
        if not farmer1:
            farmer1 = User(
                phone_number="+919876543210",
                hashed_password=get_password_hash("Farmer@123"),
                full_name="Ravi Kumar",
                role=UserRole.FARMER,
                preferred_language="ml",
                is_active=True,
            )
            db.add(farmer1)
            db.flush()

            profile1 = FarmerProfile(
                user_id=farmer1.id,
                state="Kerala",
                district="Palakkad",
                sub_district="Alathur",
                village="Kavassery",
                latitude=10.6384,
                longitude=76.4950,
                voice_preference=True,
            )
            db.add(profile1)
            db.flush()

            plot1 = AgriculturalPlot(
                farmer_profile_id=profile1.id,
                plot_name="East Paddy Field",
                acreage=3.5,
                soil_type="Clay Loam",
                water_source="Canal Irrigation",
                latitude=10.6384,
                longitude=76.4950,
            )
            plot2 = AgriculturalPlot(
                farmer_profile_id=profile1.id,
                plot_name="Coconut Grove",
                acreage=1.5,
                soil_type="Laterite Soil",
                water_source="Borewell",
                latitude=10.6390,
                longitude=76.4960,
            )
            livestock1 = LivestockUnit(
                farmer_profile_id=profile1.id,
                animal_type="Cow",
                breed="Vechur / Crossbred Jersey",
                head_count=4,
                purpose="DAIRY",
            )
            poultry1 = PoultryUnit(
                farmer_profile_id=profile1.id,
                bird_type="Hen",
                bird_count=45,
                purpose="EGGS",
            )
            aqua1 = AquacultureUnit(
                farmer_profile_id=profile1.id,
                pond_name="South Pond",
                pond_size_acres=0.5,
                fish_species="Rohu, Catla, Freshwater Prawn",
                water_type="FRESHWATER",
            )
            db.add_all([plot1, plot2, livestock1, poultry1, aqua1])

            # Sample Soil Health Card
            shc1 = FarmerSoilHealthCard(
                farmer_profile_id=profile1.id,
                plot_id=None,
                shc_number="SHC-KL-PLK-2026-0091",
                ph_level=6.2,
                organic_carbon_percent=0.85,
                nitrogen_status="MEDIUM",
                phosphorus_status="HIGH",
                potassium_status="MEDIUM",
                testing_lab_name="District Soil Testing Laboratory, Palakkad",
                issue_date=datetime.now(timezone.utc),
            )
            db.add(shc1)

        buyer1 = db.query(User).filter_by(phone_number="+919876543220").first()
        if not buyer1:
            buyer1 = User(
                phone_number="+919876543220",
                hashed_password=get_password_hash("Buyer@123"),
                full_name="Organic Green Mart",
                role=UserRole.BUYER,
                preferred_language="ml",
                is_active=True,
            )
            db.add(buyer1)

        db.commit()

        # 3. Official Fertilizer MRP Registry
        if db.query(OfficialFertilizerMRP).count() == 0:
            fertilizers = [
                ("IFFCO-UREA-45KG-2026", "IFFCO", "Neem Coated Urea (45kg)", 266.50),
                ("KRIBHCO-DAP-50KG-2026", "KRIBHCO", "Di-Ammonium Phosphate (DAP 50kg)", 1350.00),
                ("IPL-MOP-50KG-2026", "IPL", "Muriate of Potash (MOP 50kg)", 1700.00),
                ("FACT-FACTAMFOS-50KG", "FACT", "Factamfos 20:20:0:13 (50kg)", 1250.00),
            ]
            for batch, mfg, name, mrp in fertilizers:
                m_hash = calculate_sha256(f"{batch}:{mfg}:{name}:{mrp}")
                qr = json.dumps({"batch": batch, "mfg": mfg, "name": name, "mrp": mrp, "hash": m_hash})
                db.add(OfficialFertilizerMRP(
                    batch_number=batch,
                    manufacturer=mfg,
                    fertilizer_name=name,
                    official_mrp_inr=mrp,
                    merkle_hash=m_hash,
                    qr_code_payload=qr,
                ))

        # 4. Verified Produce Stock
        if db.query(VerifiedProduceStock).count() == 0:
            farmer_prof = db.query(FarmerProfile).first()
            if farmer_prof:
                batches = [
                    ("PROD-PLK-PADDY-2026-A1", "Paddy (Palakkad Matta)", 1500.0, "kg"),
                    ("PROD-PLK-COCONUT-2026-B2", "Raw Coconut", 3000.0, "piece"),
                    ("PROD-PLK-MILK-2026-C3", "Fresh Cow Milk", 200.0, "liter"),
                ]
                for p_batch, p_type, qty, unit in batches:
                    p_hash = calculate_sha256(f"{p_batch}:{farmer_prof.id}:{p_type}:{qty}:{unit}")
                    qr = json.dumps({"produce_batch_id": p_batch, "type": p_type, "qty": qty, "unit": unit, "hash": p_hash})
                    db.add(VerifiedProduceStock(
                        produce_batch_id=p_batch,
                        farmer_profile_id=farmer_prof.id,
                        produce_type=p_type,
                        quantity=qty,
                        quantity_unit=unit,
                        merkle_hash=p_hash,
                        qr_code_payload=qr,
                    ))

        # 5. Economic Indices (Fuel, Fertilizer, Feed, Labour, Transport)
        if db.query(FuelPriceIndex).count() == 0:
            db.add(FuelPriceIndex(
                state="Kerala",
                district="Palakkad",
                diesel_rate_per_liter=95.12,
                petrol_rate_per_liter=106.85,
                official_source="PPAC Portal",
            ))
            db.add(FuelPriceIndex(
                state="Tamil Nadu",
                district="Coimbatore",
                diesel_rate_per_liter=92.75,
                petrol_rate_per_liter=101.40,
                official_source="PPAC Portal",
            ))

        if db.query(FertilizerPriceIndex).count() == 0:
            db.add(FertilizerPriceIndex(
                fertilizer_type="Urea (Neem Coated)",
                bag_weight_kg=45.0,
                official_mrp_per_bag=266.50,
                state="Kerala",
                state_subsidy_offset=0.0,
                effective_price_per_bag=266.50,
                official_source="mFMS Portal",
            ))
            db.add(FertilizerPriceIndex(
                fertilizer_type="DAP",
                bag_weight_kg=50.0,
                official_mrp_per_bag=1350.00,
                state="Kerala",
                state_subsidy_offset=0.0,
                effective_price_per_bag=1350.00,
                official_source="mFMS Portal",
            ))

        if db.query(LabourRateIndex).count() == 0:
            db.add(LabourRateIndex(
                state="Kerala",
                district="Palakkad",
                labour_type="Field Labour (Harvesting & Tilling)",
                rate_per_day_inr=850.0,
                season="Kharif",
                official_source="Kerala Labour Department",
            ))
            db.add(LabourRateIndex(
                state="Tamil Nadu",
                district="Coimbatore",
                labour_type="Field Labour",
                rate_per_day_inr=600.0,
                season="Kharif",
                official_source="Tamil Nadu Labour Department",
            ))

        if db.query(MarketPriceTrend).count() == 0:
            trends = [
                ("Paddy (Dhan) Common", "CROP", "Kerala", "Palakkad", "Palakkad APMC", 2820.0, 2600.0, 2950.0, "quintal"),
                ("Coconut", "CROP", "Kerala", "Palakkad", "Kavassery Local Market", 32.0, 28.0, 36.0, "piece"),
                ("Cow Milk (A2)", "DAIRY", "Kerala", "Palakkad", "Milma Alathur Dairy", 48.0, 44.0, 52.0, "liter"),
                ("Eggs (Desi)", "POULTRY", "Kerala", "Palakkad", "Palakkad Wholesale", 6.5, 5.8, 7.2, "piece"),
                ("Rohu / Fresh Fish", "AQUACULTURE", "Kerala", "Palakkad", "Matsyafed Palakkad", 180.0, 160.0, 210.0, "kg"),
                ("Banana (Nendran)", "CROP", "Kerala", "Palakkad", "Palakkad Mandi", 4200.0, 3800.0, 4600.0, "quintal"),
            ]
            for comm, sec, st, dist, mandi, modal, p_min, p_max, u in trends:
                db.add(MarketPriceTrend(
                    commodity_name=comm,
                    sector=sec,
                    state=st,
                    district=dist,
                    mandi_name=mandi,
                    modal_price=modal,
                    min_price=p_min,
                    max_price=p_max,
                    price_unit=u,
                    official_source="Agmarknet / State Marketing Board",
                ))

        # 6. District Soil Survey
        if db.query(DistrictSoilSurvey).count() == 0:
            db.add(DistrictSoilSurvey(
                state="Kerala",
                district="Palakkad",
                taluk_block="Alathur",
                village_panchayath="Kavassery",
                latitude=10.6384,
                longitude=76.4950,
                soil_type="Clay Loam",
                ph_level=6.2,
                electrical_conductivity_ec=0.35,
                organic_carbon_percent=0.82,
                nitrogen_kg_per_hectare=240.0,
                phosphorus_kg_per_hectare=22.5,
                potassium_kg_per_hectare=185.0,
                surveyor_name="State Soil Survey & Land Use Board",
            ))

        # 7. Seed Government Schemes from schemes_seed.json if empty
        if db.query(Scheme).count() == 0:
            seed_path = os.path.join(os.path.dirname(__file__), "..", "app", "data", "schemes_seed.json")
            if os.path.exists(seed_path):
                with open(seed_path, "r", encoding="utf-8") as f:
                    schemes_data = json.load(f)
                    for item in schemes_data:
                        db.add(Scheme(
                            code=item.get("code"),
                            name=item.get("name"),
                            level=item.get("level", "CENTRAL"),
                            state=item.get("state"),
                            category=item.get("category"),
                            sector=item.get("sector", "ALL"),
                            description=item.get("description"),
                            benefits=item.get("benefits", []),
                            eligibility=item.get("eligibility", []),
                            application_process=item.get("application_process", []),
                            documents=item.get("documents", []),
                            official_url=item.get("official_url"),
                            is_active=True,
                        ))

        # 8. Verified Marketplace Products across Sectors
        if db.query(Product).count() == 0:
            farmer_u = db.query(User).filter_by(phone_number="+919876543210").first()
            if farmer_u:
                exp = datetime.now(timezone.utc) + timedelta(days=90)
                p1 = Product(
                    farmer_id=farmer_u.id,
                    name="Organic Palakkad Matta Rice",
                    crop_type="Paddy",
                    sector="CROPS",
                    quality_grade="A",
                    district="Palakkad",
                    quantity=1500.0,
                    unit="kg",
                    price_per_unit=55.0,
                    description="Naturally grown traditional red Matta rice harvested from Alathur fields.",
                    is_active=True,
                    expires_at=exp,
                )
                p2 = Product(
                    farmer_id=farmer_u.id,
                    name="Farm Fresh Country Desi Eggs",
                    crop_type="Country Eggs",
                    sector="POULTRY",
                    quality_grade="A",
                    district="Palakkad",
                    quantity=300.0,
                    unit="piece",
                    price_per_unit=7.0,
                    description="Free-range country chicken eggs gathered daily morning.",
                    is_active=True,
                    expires_at=exp,
                )
                p3 = Product(
                    farmer_id=farmer_u.id,
                    name="Organic Fresh A2 Raw Cow Milk",
                    crop_type="Cow Milk",
                    sector="DAIRY",
                    quality_grade="A",
                    district="Palakkad",
                    quantity=150.0,
                    unit="liter",
                    price_per_unit=52.0,
                    description="Pure unadulterated crossbred Jersey cow milk from Alathur dairy herd.",
                    is_active=True,
                    expires_at=exp,
                )
                p4 = Product(
                    farmer_id=farmer_u.id,
                    name="Export Quality Nendran Banana",
                    crop_type="Banana (Nendran)",
                    sector="CROPS",
                    quality_grade="A",
                    district="Thrissur",
                    quantity=800.0,
                    unit="kg",
                    price_per_unit=42.0,
                    description="GI-tagged organically nurtured Nendran bananas for wholesale & retail.",
                    is_active=True,
                    expires_at=exp,
                )
                p5 = Product(
                    farmer_id=farmer_u.id,
                    name="GI Vazhakulam Golden Pineapple",
                    crop_type="Pineapple",
                    sector="CROPS",
                    quality_grade="A",
                    district="Ernakulam",
                    quantity=600.0,
                    unit="kg",
                    price_per_unit=38.0,
                    description="Sun-ripened sweet Vazhakulam GI pineapples directly from farm orchards.",
                    is_active=True,
                    expires_at=exp,
                )
                db.add_all([p1, p2, p3, p4, p5])

        db.commit()
        print("Database successfully verified and initialized.")
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
