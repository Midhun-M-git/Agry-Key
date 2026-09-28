"""Emergency veterinary hospital and doctor contact discovery router."""

from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.service import VeterinaryService

router = APIRouter(prefix="/services", tags=["Agricultural & Veterinary Services"])


class VeterinaryServiceResponse(BaseModel):
    id: int
    clinic_name: str
    doctor_name: str
    district: str
    sub_district: str
    phone_number: str
    latitude: float
    longitude: float
    service_type: str

    model_config = ConfigDict(from_attributes=True)


DEFAULT_VET_CENTERS = [
    {
        "clinic_name": "Government Veterinary Hospital, Palakkad",
        "doctor_name": "Dr. K. S. Radhakrishnan, Senior Vet Surgeon",
        "district": "Palakkad",
        "sub_district": "Palakkad Town",
        "phone_number": "+919447012345",
        "latitude": 10.7867,
        "longitude": 76.6548,
        "service_type": "CATTLE_POULTRY",
    },
    {
        "clinic_name": "Alathur Veterinary Polyclinic & Mobile Unit",
        "doctor_name": "Dr. Ananya Nair, Livestock Specialist",
        "district": "Palakkad",
        "sub_district": "Alathur",
        "phone_number": "+919447054321",
        "latitude": 10.6433,
        "longitude": 76.5417,
        "service_type": "CATTLE_GOAT_DAIRY",
    },
    {
        "clinic_name": "Chittur Taluk Veterinary Hospital",
        "doctor_name": "Dr. R. Murugesan, Vet Officer",
        "district": "Palakkad",
        "sub_district": "Chittur",
        "phone_number": "+919447098765",
        "latitude": 10.6975,
        "longitude": 76.8184,
        "service_type": "CATTLE_POULTRY",
    },
    {
        "clinic_name": "Coimbatore Central Veterinary Poly-Clinic",
        "doctor_name": "Dr. S. Shanmugam, Chief Veterinary Surgeon",
        "district": "Coimbatore",
        "sub_district": "Coimbatore South",
        "phone_number": "+919842112233",
        "latitude": 11.0168,
        "longitude": 76.9558,
        "service_type": "CATTLE_POULTRY_EQUINE",
    },
    {
        "clinic_name": "Pollachi Veterinary Hospital & AI Center",
        "doctor_name": "Dr. M. Deepa, Veterinary Officer",
        "district": "Coimbatore",
        "sub_district": "Pollachi",
        "phone_number": "+919842155667",
        "latitude": 10.6583,
        "longitude": 77.0089,
        "service_type": "CATTLE_DAIRY",
    },
]


def _ensure_default_vets(db: Session):
    count = db.query(VeterinaryService).count()
    if count == 0:
        for vet in DEFAULT_VET_CENTERS:
            rec = VeterinaryService(**vet)
            db.add(rec)
        db.commit()


@router.get("/veterinary", response_model=List[VeterinaryServiceResponse])
def get_veterinary_contacts(
    district: Optional[str] = Query(default=None),
    sub_district: Optional[str] = Query(default=None),
    service_type: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    """Retrieve nearby veterinary hospitals, specialists, and emergency phone contacts."""
    _ensure_default_vets(db)
    query = db.query(VeterinaryService)
    if district:
        query = query.filter(VeterinaryService.district.ilike(f"%{district.strip()}%"))
    if sub_district:
        query = query.filter(VeterinaryService.sub_district.ilike(f"%{sub_district.strip()}%"))
    if service_type:
        query = query.filter(VeterinaryService.service_type.ilike(f"%{service_type.strip()}%"))

    results = query.all()
    if not results and district:
        # Fallback to all centers if specific district not yet matched
        results = db.query(VeterinaryService).all()
    return results
