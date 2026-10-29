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
    Activated when OTP_PROVIDER=msg91/sms/twilio and valid credentials are provided.
    """

    async def send_otp(self, phone_number: str, otp_code: str) -> bool:
        provider = (getattr(settings, "OTP_PROVIDER", "") or getattr(settings, "SMS_PROVIDER", "") or "twilio").lower()
        if provider in ("msg91", "sms") or (getattr(settings, "SMS_PROVIDER", "") or "").lower() == "msg91":
            # MSG91 Provider
            auth_key = getattr(settings, "SMS_API_KEY", "") or getattr(settings, "MSG91_AUTH_KEY", "") or os.environ.get("MSG91_AUTHKEY", "") or os.environ.get("MSG91_AUTH_KEY", "")
            if not auth_key:
                logger.error("MSG91 auth key missing. Set SMS_API_KEY or MSG91_AUTH_KEY.")
                return False

            # MSG91 expects mobile number without leading '+'
            clean_mobile = phone_number.lstrip("+").strip()
            template_id = getattr(settings, "SMS_OTP_TEMPLATE_ID", "") or getattr(settings, "MSG91_TEMPLATE_ID", "") or os.environ.get("MSG91_TEMPLATE_ID", "")

            payload = {
                "mobile": clean_mobile,
                "otp": otp_code,
                "otp_expiry": "5",
            }
            if template_id:
                payload["template_id"] = template_id

            try:
                url = "https://control.msg91.com/api/v5/otp"
                if template_id:
                    url = f"{url}?template_id={template_id}&mobile={clean_mobile}&otp={otp_code}&otp_expiry=5"
                async with httpx.AsyncClient(timeout=10) as client:
                    response = await client.post(
                        url,
                        headers={
                            "authkey": auth_key,
                            "Content-Type": "application/json",
                        },
                        json=payload,
                    )
                    data = response.json() if "application/json" in response.headers.get("content-type", "") else {}
                    if response.status_code in (200, 201) and data.get("type") != "error":
                        logger.info(f"MSG91 OTP dispatched successfully to {clean_mobile}")
                        return True
                    else:
                        logger.error(f"MSG91 delivery failed ({response.status_code}): {response.text}")
                        return False
            except Exception as exc:
                logger.error(f"MSG91 delivery failed: {exc}")
                return False
        else:
            # Twilio Provider
            account_sid, auth_token, _, from_number = _get_twilio_config()
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


def get_otp_provider() -> OTPProvider:
    """Factory selecting the active OTP provider based on environment configuration."""
    provider_type = (getattr(settings, "OTP_PROVIDER", "") or "").lower()
    sms_provider = (getattr(settings, "SMS_PROVIDER", "") or "").lower()
    auth_key = getattr(settings, "SMS_API_KEY", "") or getattr(settings, "MSG91_AUTH_KEY", "") or os.environ.get("MSG91_AUTHKEY", "") or os.environ.get("MSG91_AUTH_KEY", "")

    # Prioritize MSG91 if explicitly configured
    if (provider_type in ("msg91", "sms") or sms_provider == "msg91") and auth_key and auth_key not in ("mock", "test", ""):
        return SMSOTPProvider()

    account_sid, auth_token, service_sid, _ = _get_twilio_config()
    if account_sid and auth_token:
        if service_sid:
            return TwilioVerifyOTPProvider()
        return SMSOTPProvider()

    if auth_key and auth_key not in ("mock", "test", ""):
        return SMSOTPProvider()

    return DevelopmentOTPProvider()
