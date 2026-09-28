"""OTP delivery provider abstraction supporting Development and Production SMS modes."""

import abc
import logging
import httpx
from app.core.config import settings

logger = logging.getLogger("otp_provider")


class OTPProvider(abc.ABC):
    """Abstract base class for Agry-Key OTP delivery providers."""

    @abc.abstractmethod
    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        """Dispatches an OTP to the given phone number."""
        pass


class DevelopmentOTPProvider(OTPProvider):
    """
    Zero-budget development and testing OTP provider.
    Outputs the OTP exclusively to backend server console logs.
    Never exposes the OTP in API responses.
    """

    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        banner = (
            "\n====================================\n"
            " AGRY-KEY DEVELOPMENT OTP\n"
            f" Phone: {phone_number}\n"
            f" OTP: {otp_code}\n"
            " Expires: 5 minutes\n"
            "====================================\n"
        )
        print(banner, flush=True)
        logger.info(f"Agry-Key Dev OTP: {phone_number} -> {otp_code}")
        return True


class SMSOTPProvider(OTPProvider):
    """
    Production SMS provider supporting MSG91, Twilio, and external SMS gateways.
    Activated when OTP_PROVIDER=sms and valid credentials are provided.
    """

    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        provider = (settings.SMS_PROVIDER or "msg91").lower()
        if provider == "twilio":
            if not (settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_FROM_NUMBER):
                logger.error("Twilio SMS credentials incomplete. Cannot deliver SMS.")
                return False
            try:
                url = f"https://api.twilio.com/2010-04-01/Accounts/{settings.TWILIO_ACCOUNT_SID}/Messages.json"
                async with httpx.AsyncClient(timeout=10) as client:
                    response = await client.post(
                        url,
                        auth=(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN),
                        data={
                            "From": settings.TWILIO_FROM_NUMBER,
                            "To": phone_number,
                            "Body": f"Your Agry-Key verification code is {otp_code}. Valid for 5 minutes.",
                        },
                    )
                    response.raise_for_status()
                    return True
            except Exception as exc:
                logger.error(f"Twilio delivery failed: {exc}")
                return False
        else:
            # MSG91
            if not settings.SMS_API_KEY:
                logger.error("MSG91 auth key missing. Cannot deliver SMS.")
                return False
            payload = {
                "mobile": phone_number,
                "otp": otp_code,
                "otp_expiry": "5",
            }
            if settings.SMS_OTP_TEMPLATE_ID:
                payload["template_id"] = settings.SMS_OTP_TEMPLATE_ID
            try:
                async with httpx.AsyncClient(timeout=10) as client:
                    response = await client.post(
                        "https://control.msg91.com/api/v5/otp",
                        headers={
                            "authkey": settings.SMS_API_KEY,
                            "Content-Type": "application/json",
                        },
                        json=payload,
                    )
                    response.raise_for_status()
                    return True
            except Exception as exc:
                logger.error(f"MSG91 delivery failed: {exc}")
                return False


def get_otp_provider() -> OTPProvider:
    """Factory selecting the active OTP provider based on environment configuration."""
    provider_type = (getattr(settings, "OTP_PROVIDER", "development") or "development").lower()
    if provider_type == "sms" and settings.SMS_API_KEY and settings.SMS_API_KEY not in ("mock", "test", ""):
        return SMSOTPProvider()
    return DevelopmentOTPProvider()
