"""OTP delivery provider abstraction supporting Development and Production SMS modes (Twilio Verify & SMS gateways)."""

import abc
import logging
import os
import httpx
from app.core.config import settings

logger = logging.getLogger("otp_provider")


def _get_twilio_config():
    """Retrieves Twilio configuration from settings or environment variables."""
    sid = getattr(settings, "TWILIO_ACCOUNT_SID", None) or os.environ.get("TWILIO_ACCOUNT_SID", "")
    token = getattr(settings, "TWILIO_AUTH_TOKEN", None) or os.environ.get("TWILIO_AUTH_TOKEN", "")
    service = getattr(settings, "TWILIO_VERIFY_SERVICE_SID", None) or os.environ.get("TWILIO_VERIFY_SERVICE_SID", "")
    from_num = getattr(settings, "TWILIO_FROM_NUMBER", None) or os.environ.get("TWILIO_FROM_NUMBER", "")
    return sid, token, service, from_num


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


class TwilioVerifyOTPProvider(OTPProvider):
    """
    Twilio Verify API Provider.
    Sends authentic, carrier-grade verification SMS to Indian (+91) and international mobile numbers.
    Fully compatible with Twilio trial accounts and production verified services.
    """

    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        account_sid, auth_token, service_sid, _ = _get_twilio_config()
        if not (account_sid and auth_token and service_sid):
            logger.error("Twilio Verify credentials incomplete. Cannot dispatch SMS.")
            fallback = SMSOTPProvider()
            return await fallback.send_otp(phone_number, otp_code)

        url = f"https://verify.twilio.com/v2/Services/{service_sid}/Verifications"
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                res = await client.post(
                    url,
                    auth=(account_sid, auth_token),
                    data={"To": phone_number, "Channel": "sms"},
                )
                if res.status_code in (200, 201):
                    logger.info(f"Twilio Verify SMS dispatched successfully to {phone_number}")
                    return True
                else:
                    logger.error(f"Twilio Verify failed: {res.status_code} - {res.text}")
                    # Fallback to standard SMS provider if service fails
                    fallback = SMSOTPProvider()
                    return await fallback.send_otp(phone_number, otp_code)
        except Exception as exc:
            logger.error(f"Twilio Verify error: {exc}")
            fallback = SMSOTPProvider()
            return await fallback.send_otp(phone_number, otp_code)

    @staticmethod
    async def verify_code(phone_number: str, code: str) -> bool:
        account_sid, auth_token, service_sid, _ = _get_twilio_config()
        if not (account_sid and auth_token and service_sid):
            return False

        url = f"https://verify.twilio.com/v2/Services/{service_sid}/VerificationCheck"
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                res = await client.post(
                    url,
                    auth=(account_sid, auth_token),
                    data={"To": phone_number, "Code": code.strip()},
                )
                if res.status_code in (200, 201):
                    data = res.json()
                    return data.get("status") == "approved" or data.get("valid") is True
                return False
        except Exception as exc:
            logger.error(f"Twilio verify check error: {exc}")
            return False


class SMSOTPProvider(OTPProvider):
    """
    Production SMS provider supporting MSG91, Twilio, and external SMS gateways.
    Activated when OTP_PROVIDER=sms/twilio and valid credentials are provided.
    """

    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        account_sid, auth_token, _, from_number = _get_twilio_config()
        provider = (settings.SMS_PROVIDER or "twilio").lower()
        if provider == "twilio":
            if not (account_sid and auth_token and from_number):
                logger.error("Twilio SMS credentials incomplete. Cannot deliver SMS.")
                return False
            try:
                url = f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json"
                async with httpx.AsyncClient(timeout=10) as client:
                    response = await client.post(
                        url,
                        auth=(account_sid, auth_token),
                        data={
                            "From": from_number,
                            "To": phone_number,
                            "Body": f"Your Agry-Key verification code is {otp_code}. Valid for 5 minutes.",
                        },
                    )
                    response.raise_for_status()
                    return True
            except Exception as exc:
                logger.error(f"Twilio standard SMS delivery failed: {exc}")
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
    account_sid, auth_token, service_sid, _ = _get_twilio_config()
    if account_sid and auth_token:
        if service_sid:
            return TwilioVerifyOTPProvider()
        return SMSOTPProvider()

    provider_type = (getattr(settings, "OTP_PROVIDER", "development") or "development").lower()
    if provider_type == "sms" and settings.SMS_API_KEY and settings.SMS_API_KEY not in ("mock", "test", ""):
        return SMSOTPProvider()

    return DevelopmentOTPProvider()
