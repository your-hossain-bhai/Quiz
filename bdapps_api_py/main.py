from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from bdapps import BDAppsClient
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="BDApps Quiz App API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

bdapps = BDAppsClient()


class OTPRequest(BaseModel):
    user_mobile: str


class OTPVerifyRequest(BaseModel):
    referenceNo: str
    otp: str


class SubscriptionCheckRequest(BaseModel):
    user_mobile: str


@app.post("/otp/send")
async def send_otp(req: OTPRequest):
    try:
        resp = await bdapps.request_otp(req.user_mobile)

        ref_no = resp.get("referenceNo", "")
        if ref_no:
            return {
                "success": True,
                "referenceNo": ref_no,
                "statusCode": resp.get("statusCode", ""),
                "statusDetail": resp.get("statusDetail", ""),
                "version": resp.get("version", ""),
            }
        else:
            return {
                "success": False,
                "message": resp.get("statusDetail", "OTP reference not returned"),
                "referenceNo": None,
                "statusCode": resp.get("statusCode", ""),
                "statusDetail": resp.get("statusDetail", ""),
                "version": resp.get("version", ""),
                "subscriberId": req.user_mobile,
            }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/otp/verify")
async def verify_otp(req: OTPVerifyRequest):
    try:
        resp = await bdapps.verify_otp(req.referenceNo, req.otp)
        return resp
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/subscription/check")
async def check_subscription(req: SubscriptionCheckRequest):
    try:
        resp = await bdapps.get_status(req.user_mobile)
        status = str(resp.get("subscriptionStatus", "")).upper()
        return {
            "subscriptionStatus": status,
            "isSubscribed": (status == "REGISTERED"),
            "statusCode": resp.get("statusCode"),
            "statusDetail": resp.get("statusDetail"),
            "version": resp.get("version"),
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/subscription/unsubscribe")
async def unsubscribe(req: SubscriptionCheckRequest):
    try:
        resp = await bdapps.unsubscribe(req.user_mobile)
        status_code = str(resp.get("statusCode", "")).upper()
        sub_status = str(resp.get("subscriptionStatus", "")).upper()

        success = (status_code == "S1000") or (sub_status == "UNREGISTERED")
        return {
            "success": success,
            "statusCode": resp.get("statusCode"),
            "statusDetail": resp.get("statusDetail"),
            "subscriptionStatus": sub_status,
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/subscription/listener")
async def subscription_listener(request: Request):
    try:
        body = await request.json()
    except Exception:
        body = await request.body()

    print(f"Received listener notification: {body}")
    return {"status": "received"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
