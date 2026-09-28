"""Phone number normalization and cryptographic OTP hashing utilities."""

import hashlib
import re
import secrets
from typing import Optional


def normalize_indian_phone(phone: Optional[str]) -> str:
    """
    Normalizes Indian mobile numbers into standard format: +91XXXXXXXXXX
    Strips all whitespace, dashes, periods, and parentheses.
    
    Accepts:
      - 9876543210
      - 09876543210
      - 919876543210
      - +91 98765 43210
      - +919876543210
      
    Returns:
      +91XXXXXXXXXX
      
    Raises:
      ValueError if phone number is missing or invalid.
    """
    if not phone or not isinstance(phone, str):
        raise ValueError("Mobile number is required.")

    cleaned = re.sub(r"[\s\-\(\)\.]+", "", phone.strip())

    if cleaned.startswith("+91"):
        digits = cleaned[3:]
    elif cleaned.startswith("0") and len(cleaned) == 11:
        digits = cleaned[1:]
    elif cleaned.startswith("91") and len(cleaned) == 12:
        digits = cleaned[2:]
    elif cleaned.startswith("+"):
        # Other country code - keep as is if 10-15 digits
        digits = cleaned[1:]
        if not re.fullmatch(r"\d{10,15}", digits):
            raise ValueError("Invalid phone number format.")
        return f"+{digits}"
    else:
        digits = cleaned

    if not re.fullmatch(r"[6-9]\d{9}", digits):
        raise ValueError("Invalid Indian mobile number. Must be a 10-digit number starting with 6, 7, 8, or 9.")

    return f"+91{digits}"


def generate_otp_code() -> str:
    """Generates a secure, cryptographically random 6-digit OTP code."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_otp(phone_number: str, otp_code: str, secret_key: str) -> str:
    """
    Computes a SHA-256 HMAC-style hash of the OTP bound to the normalized phone number and server secret.
    Ensures plaintext OTP is never persisted in the database.
    """
    payload = f"{phone_number}:{otp_code.strip()}:{secret_key}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def verify_otp_hash(phone_number: str, otp_code: str, secret_key: str, expected_hash: str) -> bool:
    """Verifies an OTP candidate against the stored hash in constant time."""
    candidate_hash = hash_otp(phone_number, otp_code, secret_key)
    return secrets.compare_digest(candidate_hash, expected_hash)
