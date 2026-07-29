import os
import httpx
from dotenv import load_dotenv

load_dotenv()

class BDAppsClient:
    def __init__(self):
        self.app_id = os.getenv("BDAPPS_APP_ID")
        self.password = os.getenv("BDAPPS_PASSWORD")
        self.base_url = "https://developer.bdapps.com/subscription"
        
    def _format_subscriber_id(self, mobile_number: str) -> str:
        digits = ''.join(filter(str.isdigit, mobile_number))
        if digits.startswith("880") and len(digits) == 13:
            digits = "0" + digits[3:]
        elif digits.startswith("88") and len(digits) == 12:
            digits = "0" + digits[2:]
            
        if not (digits.startswith("01") and len(digits) == 11):
            raise ValueError("Invalid mobile number format")
            
        return f"tel:88{digits}"
        
    async def request_otp(self, mobile_number: str) -> dict:
        subscriber_id = self._format_subscriber_id(mobile_number)
        payload = {
            "applicationId": self.app_id,
            "password": self.password,
            "subscriberId": subscriber_id,
            "applicationHash": "App Name",
            "applicationMetaData": {
                "client": "MOBILEAPP",
                "device": "Samsung S10",
                "os": "android 8",
                "appCode": "https://play.google.com/store/apps/details?id=lk.dialog.megarunlor"
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{self.base_url}/otp/request", json=payload, timeout=30.0)
            return response.json()
            
    async def verify_otp(self, reference_no: str, otp: str) -> dict:
        payload = {
            "applicationId": self.app_id,
            "password": self.password,
            "referenceNo": reference_no,
            "otp": otp
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{self.base_url}/otp/verify", json=payload, timeout=15.0)
            return response.json()
            
    async def get_status(self, mobile_number: str) -> dict:
        subscriber_id = self._format_subscriber_id(mobile_number)
        payload = {
            "version": "1.0",
            "applicationId": self.app_id,
            "password": self.password,
            "subscriberId": subscriber_id
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{self.base_url}/getStatus", json=payload, timeout=10.0)
            return response.json()
            
    async def unsubscribe(self, mobile_number: str) -> dict:
        subscriber_id = self._format_subscriber_id(mobile_number)
        payload = {
            "version": "1.0",
            "action": "0",
            "applicationId": self.app_id,
            "password": self.password,
            "subscriberId": subscriber_id
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{self.base_url}/send", json=payload, timeout=30.0)
            return response.json()
