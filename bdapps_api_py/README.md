# BDApps Quiz App API

This is a FastAPI-based backend application for interacting with the BDApps Subscription API. It handles OTP requests, OTP verification, subscription status checks, and unsubscription requests.

## Prerequisites

- Python 3.10+
- `pip` or `uv` for package management

## Setup

1. **Navigate to the directory**:
   ```bash
   cd bdapps_api_py
   ```

2. **Create and activate a virtual environment**:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```
   *(For Windows, use `.venv\Scripts\activate`)*

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## Environment Variables

Create a `.env` file in the root of the `bdapps_api_py` directory and add your BDApps credentials:

```env
BDAPPS_APP_ID=your_app_id_here
BDAPPS_PASSWORD=your_app_password_here
```

## How to Run the App

Once your virtual environment is active and dependencies are installed, you can start the development server using Uvicorn:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Or simply run the main script directly:

```bash
python main.py
```

The API will be available at: http://127.0.0.1:8000

## API Endpoints

- `POST /otp/send`: Sends an OTP for subscription.
- `POST /otp/verify`: Verifies the OTP to complete the subscription.
- `POST /subscription/check`: Checks if a user is subscribed.
- `POST /subscription/unsubscribe`: Unsubscribes a user.
- `POST /subscription/listener`: Webhook endpoint to receive asynchronous updates from BDApps.
