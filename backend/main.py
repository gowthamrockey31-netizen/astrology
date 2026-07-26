import os
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import pymongo
import mongomock

app = FastAPI(
    title="Astrocall Backend API",
    description="FastAPI + MongoDB backend authentication service for Astrocall Digital Astrology Centre",
    version="1.0.0",
)

# Enable CORS for Flutter Web & Desktop
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB Connection with automatic Mongomock fallback
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = "astrocall_db"

try:
    mongo_client = pymongo.MongoClient(MONGO_URI, serverSelectionTimeoutMS=1500)
    mongo_client.server_info()  # Trigger exception if local mongo server is offline
    db = mongo_client[DB_NAME]
    print(f"[Connected] MongoDB server active at {MONGO_URI}")
except Exception as e:
    print(f"[Fallback] Local MongoDB server offline ({e}). Using Mongomock in-memory MongoDB engine.")
    mongo_client = mongomock.MongoClient()
    db = mongo_client[DB_NAME]

users_collection = db["users"]

# Seed initial default demo user if collection is empty
if users_collection.count_documents({}) == 0:
    users_collection.insert_one({
        "phone": "+919876543210",
        "password": "password123",
        "name": "Divine Seeker",
        "role": "user"
    })
    print("[Seeded] Created default demo user: Phone: +919876543210 / Password: password123")


# Pydantic Schemas
class UserLogin(BaseModel):
    phone: str = Field(..., example="+919876543210")
    password: str = Field(..., example="password123")

class UserRegister(BaseModel):
    phone: str = Field(..., example="+919876543210")
    password: str = Field(..., example="password123")
    name: str = Field("Divine Seeker", example="Divine Seeker")

class GoogleAuth(BaseModel):
    email: str = Field(..., example="user@gmail.com")
    name: str = Field("Google User", example="Seeker Astro")

class AuthResponse(BaseModel):
    status: str
    message: str
    phone: str
    name: str
    token: str


@app.get("/api/health")
def health_check():
    return {"status": "ok", "database": "mongodb", "service": "Astrocall Auth API"}


@app.post("/api/auth/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: UserRegister):
    phone_clean = user_data.phone.strip()
    if not phone_clean:
        raise HTTPException(status_code=400, detail="Phone number is required.")
    if not user_data.password or len(user_data.password) < 4:
        raise HTTPException(status_code=400, detail="Password must be at least 4 characters.")

    existing_user = users_collection.find_one({"phone": phone_clean})
    if existing_user:
        raise HTTPException(status_code=400, detail="An account with this phone number already exists.")

    new_user = {
        "phone": phone_clean,
        "password": user_data.password,
        "name": user_data.name.strip() or "Divine Seeker",
        "role": "user"
    }
    users_collection.insert_one(new_user)

    return AuthResponse(
        status="success",
        message="Registration successful",
        phone=phone_clean,
        name=new_user["name"],
        token="astrocall-token-" + phone_clean[-4:]
    )


@app.post("/api/auth/login", response_model=AuthResponse)
def login(credentials: UserLogin):
    phone_clean = credentials.phone.strip()
    password_clean = credentials.password.strip()

    if not phone_clean:
        raise HTTPException(status_code=400, detail="Please enter your phone number.")
    if not password_clean:
        raise HTTPException(status_code=400, detail="Please enter your password.")

    user = users_collection.find_one({"phone": phone_clean})

    # Also match phone number without leading country code (+91) for convenience
    if not user and not phone_clean.startswith("+91"):
        user = users_collection.find_one({"phone": "+91" + phone_clean})
    if not user and phone_clean.startswith("+91"):
        user = users_collection.find_one({"phone": phone_clean.replace("+91", "")})

    if not user or user.get("password") != password_clean:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone number or password. Please verify your credentials."
        )

    return AuthResponse(
        status="success",
        message="Login successful",
        phone=user["phone"],
        name=user.get("name", "Divine Seeker"),
        token="astrocall-jwt-session-" + user["phone"][-4:]
    )


@app.post("/api/auth/google", response_model=AuthResponse)
def google_auth(google_data: GoogleAuth):
    email_clean = google_data.email.strip().lower()
    if not email_clean or "@" not in email_clean:
        raise HTTPException(status_code=400, detail="Invalid Google account email.")

    user = users_collection.find_one({"email": email_clean})

    if not user:
        # Create Google account record in MongoDB if new user
        new_user = {
            "email": email_clean,
            "phone": email_clean,
            "name": google_data.name.strip() or "Google Seeker",
            "provider": "google",
            "role": "user"
        }
        users_collection.insert_one(new_user)
        user = new_user
        msg = "Google account registered and authenticated successfully!"
    else:
        msg = f"Welcome back, {user.get('name', 'Google Seeker')}!"

    return AuthResponse(
        status="success",
        message=msg,
        phone=user.get("phone", email_clean),
        name=user.get("name", "Google Seeker"),
        token="astrocall-google-token-" + email_clean[:4]
    )


@app.get("/api/auth/users")
def list_users():
    users = list(users_collection.find({}, {"_id": 0, "password": 0}))
    return {"users": users}
