"""Plant disease identification using Gemini Vision."""

import json
from typing import Any

import google.generativeai as genai
from fastapi import APIRouter, File, HTTPException, UploadFile, status
from pydantic import BaseModel, Field, ValidationError

from app.core.config import settings

router = APIRouter(prefix="/disease", tags=["Plant Disease Detection"])

_MAX_IMAGE_BYTES = 10 * 1024 * 1024
_VISION_MODEL = "gemini-1.5-flash"


class DiseaseAnalysisResponse(BaseModel):
    disease_name: str
    confidence_score: float = Field(..., ge=0, le=100)
    treatment_recommendation: str
    preventive_measures: list[str]


def _configured_gemini_key() -> str:
    api_key = settings.GEMINI_API_KEY.strip()
    if not api_key or api_key == "sample_gemini_key":
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Gemini Vision is not configured",
        )
    return api_key


def _parse_analysis(response_text: str) -> DiseaseAnalysisResponse:
    try:
        data: dict[str, Any] = json.loads(response_text)
    except json.JSONDecodeError:
        start = response_text.find("{")
        end = response_text.rfind("}")
        if start < 0 or end <= start:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Gemini returned an invalid disease analysis",
            )
        try:
            data = json.loads(response_text[start : end + 1])
        except json.JSONDecodeError as exc:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Gemini returned an invalid disease analysis",
            ) from exc

    confidence = data.get("confidence_score", data.get("confidence"))
    if isinstance(confidence, str):
        confidence = float(confidence.strip().rstrip("%"))
    if isinstance(confidence, (int, float)) and 0 <= confidence <= 1:
        confidence *= 100

    preventive_measures = data.get("preventive_measures", data.get("prevention", []))
    if isinstance(preventive_measures, str):
        preventive_measures = [preventive_measures]

    normalized = {
        "disease_name": data.get("disease_name", data.get("disease")),
        "confidence_score": confidence,
        "treatment_recommendation": data.get(
            "treatment_recommendation", data.get("treatment")
        ),
        "preventive_measures": preventive_measures,
    }
    try:
        return DiseaseAnalysisResponse.model_validate(normalized)
    except (ValidationError, TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Gemini returned an incomplete disease analysis",
        ) from exc


@router.post("/analyze", response_model=DiseaseAnalysisResponse)
def analyze_plant_disease(image: UploadFile = File(...)):
    """Identify a likely plant disease from an uploaded image."""
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Please upload a valid image file",
        )

    image_bytes = image.file.read(_MAX_IMAGE_BYTES + 1)
    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image must be 10 MB or smaller",
        )
    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded image is empty",
        )

    api_key = _configured_gemini_key()
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel(model_name=_VISION_MODEL)
        response = model.generate_content(
            [
                """
Analyze this plant image for disease or pest damage. Return only valid JSON with exactly these fields:
{
  "disease_name": "specific disease, pest damage, or Healthy",
  "confidence_score": 0,
  "treatment_recommendation": "practical treatment recommendation",
  "preventive_measures": ["preventive measure 1", "preventive measure 2"]
}
Use a confidence_score from 0 to 100. Do not invent certainty when the image is unclear.
""",
                {"mime_type": image.content_type, "data": image_bytes},
            ],
            generation_config={
                "response_mime_type": "application/json",
                "temperature": 0.2,
                "max_output_tokens": 500,
            },
        )
        response_text = getattr(response, "text", "").strip()
        if not response_text:
            raise ValueError("Gemini returned an empty response")
        return _parse_analysis(response_text)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to analyze the plant image",
        ) from exc