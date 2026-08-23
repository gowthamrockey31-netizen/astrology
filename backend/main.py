import os
import json
from typing import List, Optional, Dict, Any
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import pymongo
import mongomock

app = FastAPI(
    title="Astrocall Backend API",
    description="FastAPI + MongoDB backend authentication & management service for Astrocall Digital Astrology Centre",
    version="2.0.0",
)

# Enable CORS for Flutter Web & Desktop
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB Connection with automatic File-backed Persistent Storage Fallback
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = "astrocall_db"
PERSISTENT_FILE = os.path.join(os.path.dirname(__file__), "astrocall_mongodb_data.json")

use_real_mongo = False

try:
    mongo_client = pymongo.MongoClient(MONGO_URI, serverSelectionTimeoutMS=1500)
    mongo_client.server_info()  # Trigger exception if local mongo server is offline
    db = mongo_client[DB_NAME]
    use_real_mongo = True
    print(f"[Connected] MongoDB server active at {MONGO_URI}")
except Exception as e:
    print(f"[Fallback] Local MongoDB server offline ({e}). Using Mongomock in-memory engine with persistent JSON storage.")
    mongo_client = mongomock.MongoClient()
    db = mongo_client[DB_NAME]


def load_persistent_data():
    """Load JSON persistent backup into Mongomock collections if offline."""
    if use_real_mongo or not os.path.exists(PERSISTENT_FILE):
        return
    try:
        with open(PERSISTENT_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            for collection_name, docs in data.items():
                col = db[collection_name]
                col.delete_many({})
                if docs:
                    col.insert_many(docs)
        print(f"[Loaded] Loaded persistent database state from {PERSISTENT_FILE}")
    except Exception as e:
        print(f"[Error] Could not load persistent data file: {e}")


def save_persistent_data():
    """Save Mongomock state to JSON file for true disk persistence when offline."""
    if use_real_mongo:
        return
    try:
        collections = ["users", "astrologers", "terms_conditions", "magazine_articles", "horoscope_predictions", "wallet_transactions", "panchang_entries", "planet_positions"]
        data = {}
        for col_name in collections:
            docs = list(db[col_name].find({}, {"_id": 0}))
            data[col_name] = docs
        with open(PERSISTENT_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, default=str)
    except Exception as e:
        print(f"[Error] Could not save persistent data file: {e}")


# Initialize Collections
users_collection = db["users"]
astrologers_collection = db["astrologers"]
terms_collection = db["terms_conditions"]
magazine_collection = db["magazine_articles"]
horoscope_collection = db["horoscope_predictions"]
wallet_collection = db["wallet_transactions"]
panchang_collection = db["panchang_entries"]
planets_collection = db["planet_positions"]

load_persistent_data()

# Seed default data if empty
if users_collection.count_documents({}) == 0:
    users_collection.insert_one({
        "id": "usr_demo",
        "phone": "+919876543210",
        "mobile": "+919876543210",
        "email": "user@astrocare.com",
        "password": "password123",
        "name": "Divine Seeker",
        "role": "User",
        "gender": "Male",
        "dob": "1995-08-15",
        "timeOfBirth": "08:30 AM",
        "placeOfBirth": "Chennai, TN",
        "city": "Chennai",
        "state": "Tamil Nadu",
        "country": "India",
        "zodiac": "Leo (Simha)",
        "nakshatra": "Purva Phalguni",
        "lagna": "Leo",
        "walletBalance": 750.0,
        "profilePhoto": "",
    })

if astrologers_collection.count_documents({}) == 0:
    astrologers_collection.insert_many([
        {
            "id": "ast_1",
            "name": "Acharya Divine",
            "photoUrl": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80",
            "mobile": "+919876543211",
            "email": "acharya@astrocare.com",
            "password": "password123",
            "gender": "Male",
            "city": "Chennai",
            "state": "Tamil Nadu",
            "experienceYears": 15,
            "qualification": "Master in Vedic Astrology",
            "specializations": ["Vedic Astrology", "Nadi Astrology"],
            "languages": ["Tamil", "English"],
            "consultationFee": 30.0,
            "rating": 4.9,
            "totalReviews": 120,
            "status": "online",
            "estimatedWaitMinutes": 0,
            "verificationStatus": "approved",
        },
        {
            "id": "ast_2",
            "name": "Dr. K. Raman Acharya",
            "photoUrl": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80",
            "mobile": "+919876543212",
            "email": "raman@astrocare.com",
            "password": "password123",
            "gender": "Male",
            "city": "Coimbatore",
            "state": "Tamil Nadu",
            "experienceYears": 22,
            "qualification": "Ph.D in Astro Mathematics",
            "specializations": ["KP System", "Gemology", "Vastu Shastra"],
            "languages": ["Tamil", "English", "Telugu"],
            "consultationFee": 50.0,
            "rating": 5.0,
            "totalReviews": 340,
            "status": "online",
            "estimatedWaitMinutes": 2,
            "verificationStatus": "approved",
        }
    ])

if terms_collection.count_documents({}) == 0:
    terms_collection.insert_many([
        {
            "id": "tc_1",
            "title": "1. Service Scope & Consultation Ethics",
            "description": "Astrocare connects users with professional astrologers for spiritual guidance, horoscopes, and remedies. Consultations do not replace legal, medical, or financial advice.",
            "orderIndex": 1
        },
        {
            "id": "tc_2",
            "title": "2. User Privacy & Data Protection",
            "description": "Your birth details, birth charts, contact information, and consultation history are strictly confidential and protected with enterprise-grade encryption.",
            "orderIndex": 2
        },
        {
            "id": "tc_3",
            "title": "3. Wallet Payments & Consultation Rates",
            "description": "Consultations are billed per minute or per fixed session using your Astrocare Wallet. Sufficient balance is required to initiate Voice, Video, or Chat sessions.",
            "orderIndex": 3
        },
        {
            "id": "tc_4",
            "title": "4. Non-Disclosure & Anti-Contact Policy",
            "description": "Sharing personal phone numbers, bank details, or off-platform payment info between Users and Astrologers is strictly prohibited and subject to account suspension.",
            "orderIndex": 4
        },
        {
            "id": "tc_5",
            "title": "5. Refund & Cancellation Terms",
            "description": "If a consultation is disconnected within the first 60 seconds due to technical errors, full wallet refunds are automatically credited.",
            "orderIndex": 5
        }
    ])

if magazine_collection.count_documents({}) == 0:
    magazine_collection.insert_many([
        {
            "id": "mag_1",
            "title": "Planetary Transits of 2026: Financial & Spiritual Forecast",
            "category": "Vedic Predictions",
            "summary": "Explore how Jupiter and Saturn transits in 2026 shape global economy, personal wealth, and spiritual growth.",
            "content": "Jupiter enters a exalted placement this season, bringing financial wisdom and career promotions for Earth and Water zodiac signs. Saturn enforces discipline in debt management and long-term investments.\n\nKey Takeaways for 2026:\n• Aries & Leo: Prime time for business expansions.\n• Taurus & Virgo: Exceptional real estate and gem alignment.\n• Gemini & Libra: Spiritual travel and intellectual achievements.\n• Scorpio & Pisces: Divine relationship harmony and emotional stability.",
            "imageUrl": "https://images.unsplash.com/photo-1532693322450-2cb5c511067d?auto=format&fit=crop&w=800&q=80",
            "author": "Dr. K. Raman Acharya",
            "publishedAt": "2026-08-02T10:00:00",
            "likesCount": 342,
            "commentsCount": 45,
            "isBookmarked": True
        },
        {
            "id": "mag_2",
            "title": "Understanding Rahu & Ketu in Kundli: Myths vs Reality",
            "category": "Kundli Deep Dive",
            "summary": "Demystifying shadow planets Rahu and Ketu to unlock hidden talents and karmic rewards.",
            "content": "Rahu and Ketu are often feared, but in authentic Vedic Astrology, Rahu represents worldly ambition and technological genius, while Ketu signifies intuition and moksha.\n\nWhen placed in favorable houses (3rd, 6th, 10th, 11th), Rahu bestows sudden fame and international success.",
            "imageUrl": "https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?auto=format&fit=crop&w=800&q=80",
            "author": "Pandit V. Sharma",
            "publishedAt": "2026-07-30T10:00:00",
            "likesCount": 512,
            "commentsCount": 88,
            "isBookmarked": False
        }
    ])

if panchang_collection.count_documents({}) == 0:
    panchang_collection.insert_one({
        "id": "panchang_1",
        "date": "Today",
        "tithi": "Shukla Paksha Ekadashi (until 04:15 PM)",
        "nakshatra": "Rohini (until 08:30 PM)",
        "yoga": "Shubha (until 06:10 PM)",
        "karana": "Bava (until 04:15 PM)",
        "sunrise": "06:05 AM",
        "sunset": "06:42 PM",
        "moonrise": "03:12 PM",
        "moonset": "04:08 AM",
        "rahuKalam": "01:30 PM - 03:00 PM",
        "yamagandam": "06:00 AM - 07:30 AM",
        "kuligai": "09:00 AM - 10:30 AM",
        "auspiciousTime": "11:45 AM - 12:35 PM (Abhijit)",
        "paksha": "Shukla Paksha"
    })

if planets_collection.count_documents({}) == 0:
    planets_collection.insert_many([
        {"id": "plt_1", "planet": "Sun (Surya)", "rasi": "Cancer (Karka)", "degrees": "12° 45'", "isRetrograde": False, "nakshatra": "Pushya"},
        {"id": "plt_2", "planet": "Moon (Chandra)", "rasi": "Taurus (Vrishabha)", "degrees": "24° 10'", "isRetrograde": False, "nakshatra": "Rohini"},
        {"id": "plt_3", "planet": "Mars (Mangal)", "rasi": "Leo (Simha)", "degrees": "08° 30'", "isRetrograde": False, "nakshatra": "Magha"},
        {"id": "plt_4", "planet": "Mercury (Budha)", "rasi": "Gemini (Mithuna)", "degrees": "18° 55'", "isRetrograde": True, "nakshatra": "Ardra"},
        {"id": "plt_5", "planet": "Jupiter (Guru)", "rasi": "Taurus (Vrishabha)", "degrees": "15° 20'", "isRetrograde": False, "nakshatra": "Rohini"},
        {"id": "plt_6", "planet": "Venus (Shukra)", "rasi": "Cancer (Karka)", "degrees": "05° 40'", "isRetrograde": False, "nakshatra": "Punarvasu"},
        {"id": "plt_7", "planet": "Saturn (Shani)", "rasi": "Aquarius (Kumbha)", "degrees": "21° 15'", "isRetrograde": True, "nakshatra": "Purva Bhadrapada"},
        {"id": "plt_8", "planet": "Rahu (North Node)", "rasi": "Pisces (Meena)", "degrees": "11° 02'", "isRetrograde": True, "nakshatra": "Uttara Bhadrapada"},
        {"id": "plt_9", "planet": "Ketu (South Node)", "rasi": "Virgo (Kanya)", "degrees": "11° 02'", "isRetrograde": True, "nakshatra": "Hasta"},
    ])

save_persistent_data()


# Pydantic Schemas
class UserLogin(BaseModel):
    phone: str
    password: str
    role: Optional[str] = "User"

class UserRegister(BaseModel):
    phone: str
    password: str
    name: Optional[str] = "Divine Seeker"
    role: Optional[str] = "User"

class GoogleAuth(BaseModel):
    email: str
    name: Optional[str] = "Google User"
    role: Optional[str] = "User"

class UserModelSchema(BaseModel):
    id: Optional[str] = None
    name: str = "Divine Seeker"
    mobile: str
    email: Optional[str] = ""
    gender: Optional[str] = "Male"
    dob: Optional[str] = "1995-08-15"
    timeOfBirth: Optional[str] = "08:30 AM"
    placeOfBirth: Optional[str] = "Chennai, TN"
    city: Optional[str] = "Chennai"
    state: Optional[str] = "Tamil Nadu"
    country: Optional[str] = "India"
    zodiac: Optional[str] = "Leo (Simha)"
    nakshatra: Optional[str] = "Purva Phalguni"
    lagna: Optional[str] = "Leo"
    walletBalance: Optional[float] = 750.0
    role: Optional[str] = "User"
    profilePhoto: Optional[str] = ""
    pinnedAstrologers: Optional[List[str]] = []

class AstrologerSchema(BaseModel):
    id: Optional[str] = None
    name: str
    photoUrl: Optional[str] = ""
    mobile: Optional[str] = ""
    email: Optional[str] = ""
    password: Optional[str] = "password123"
    gender: Optional[str] = "Male"
    city: Optional[str] = "Chennai"
    state: Optional[str] = "Tamil Nadu"
    experienceYears: Optional[int] = 10
    qualification: Optional[str] = "Vedic Astrologer"
    specializations: Optional[List[str]] = []
    languages: Optional[List[str]] = []
    consultationFee: Optional[float] = 30.0
    rating: Optional[float] = 5.0
    totalReviews: Optional[int] = 0
    status: Optional[str] = "online"
    estimatedWaitMinutes: Optional[int] = 0
    verificationStatus: Optional[str] = "approved"

class TermSchema(BaseModel):
    id: Optional[str] = None
    title: str
    description: str
    orderIndex: Optional[int] = 1

class MagazineArticleSchema(BaseModel):
    id: Optional[str] = None
    title: str
    category: str
    summary: str
    content: str
    imageUrl: Optional[str] = ""
    videoUrl: Optional[str] = ""
    author: Optional[str] = "Astrocare Editorial"
    publishedAt: Optional[str] = ""
    likesCount: Optional[int] = 0
    commentsCount: Optional[int] = 0
    isBookmarked: Optional[bool] = False

class HoroscopePredictionSchema(BaseModel):
    zodiacSign: str
    daily: Optional[str] = ""
    weekly: Optional[str] = ""
    monthly: Optional[str] = ""
    yearly: Optional[str] = ""
    luckyNumber: Optional[int] = 7
    luckyColor: Optional[str] = "Golden Yellow"
    luckyGem: Optional[str] = "Yellow Sapphire"
    compatibilityScore: Optional[int] = 92

class WalletTransactionSchema(BaseModel):
    id: Optional[str] = None
    userId: str
    title: str
    type: str
    amount: float
    paymentMethod: str
    status: str
    timestamp: str
    referenceId: str

class PanchangSchema(BaseModel):
    id: Optional[str] = None
    date: Optional[str] = "Today"
    tithi: str
    nakshatra: str
    yoga: Optional[str] = "Shubha"
    karana: Optional[str] = "Bava"
    sunrise: Optional[str] = "06:05 AM"
    sunset: Optional[str] = "06:42 PM"
    moonrise: Optional[str] = "03:12 PM"
    moonset: Optional[str] = "04:08 AM"
    rahuKalam: str
    yamagandam: Optional[str] = "06:00 AM - 07:30 AM"
    kuligai: Optional[str] = "09:00 AM - 10:30 AM"
    auspiciousTime: Optional[str] = "11:45 AM - 12:35 PM"
    paksha: Optional[str] = "Shukla Paksha"

class PlanetPositionSchema(BaseModel):
    id: Optional[str] = None
    planet: str
    rasi: str
    degrees: str
    isRetrograde: Optional[bool] = False
    nakshatra: Optional[str] = ""


# API Routes

@app.get("/api/health")
def health_check():
    return {
        "status": "ok",
        "database": "mongodb",
        "mode": "live_mongo" if use_real_mongo else "persistent_file_fallback",
        "service": "Astrocall Auth & Data API"
    }


# AUTH & USER PROFILES
@app.post("/api/auth/register", status_code=status.HTTP_201_CREATED)
def register(user_data: UserRegister):
    phone_clean = user_data.phone.strip()
    if not phone_clean:
        raise HTTPException(status_code=400, detail="Phone number is required.")
    if not user_data.password or len(user_data.password) < 4:
        raise HTTPException(status_code=400, detail="Password must be at least 4 characters.")

    existing_user = users_collection.find_one({"mobile": phone_clean}) or users_collection.find_one({"phone": phone_clean})
    if existing_user:
        existing_user.pop("_id", None)
        return {"status": "success", "message": "Account exists, logged in.", "user": existing_user}

    user_id = f"usr_{os.urandom(4).hex()}"
    new_user = {
        "id": user_id,
        "phone": phone_clean,
        "mobile": phone_clean,
        "password": user_data.password,
        "name": user_data.name.strip() or "Divine Seeker",
        "role": user_data.role or "User",
        "gender": "Male",
        "dob": "1998-05-20",
        "timeOfBirth": "07:15 AM",
        "placeOfBirth": "Mumbai, MH",
        "city": "Mumbai",
        "state": "Maharashtra",
        "country": "India",
        "zodiac": "Taurus (Vrishabha)",
        "nakshatra": "Rohini",
        "lagna": "Taurus",
        "walletBalance": 500.0 if user_data.role == "User" else 9999.0,
        "profilePhoto": "",
    }
    users_collection.insert_one(new_user)
    save_persistent_data()

    new_user.pop("_id", None)
    return {"status": "success", "message": "Registration successful", "user": new_user}


@app.post("/api/auth/login")
def login(credentials: UserLogin):
    input_clean = credentials.phone.strip()
    password_clean = credentials.password.strip()

    is_email = "@" in input_clean

    if credentials.role == "Astrologer":
        # Strict login logic for Astrologer: MUST exist with assigned email/phone and password
        ast = None
        if is_email:
            ast = astrologers_collection.find_one({"email": input_clean.lower()})
        else:
            ast = astrologers_collection.find_one({"mobile": input_clean}) or astrologers_collection.find_one({"phone": input_clean})
        
        if not ast:
            # Also check users_collection for role Astrologer
            usr = None
            if is_email:
                usr = users_collection.find_one({"email": input_clean.lower(), "role": "Astrologer"})
            else:
                usr = users_collection.find_one({"mobile": input_clean, "role": "Astrologer"})
            if not usr:
                raise HTTPException(status_code=401, detail="Invalid Astrologer credentials. Astrologers must login using their assigned credentials.")
            if usr.get("password") and usr.get("password") != password_clean:
                raise HTTPException(status_code=401, detail="Incorrect password for Astrologer account.")
            usr.pop("_id", None)
            return {"status": "success", "message": "Astrologer login successful", "user": usr}

        # Check password on astrologer document
        ast_pwd = ast.get("password", "password123")
        if ast_pwd != password_clean:
            raise HTTPException(status_code=401, detail="Incorrect password for Astrologer account.")

        user = {
            "id": ast.get("id"),
            "email": ast.get("email"),
            "mobile": ast.get("mobile"),
            "phone": ast.get("mobile"),
            "password": ast_pwd,
            "name": ast.get("name"),
            "role": "Astrologer",
            "walletBalance": 102400.0,
        }
        users_collection.update_one({"id": ast.get("id")}, {"$set": user}, upsert=True)
        save_persistent_data()
        user.pop("_id", None)
        return {"status": "success", "message": "Astrologer login successful", "user": user}

    # For User / Admin roles:
    user = None
    if is_email:
        user = users_collection.find_one({"email": input_clean.lower()})
    else:
        user = users_collection.find_one({"mobile": input_clean}) or users_collection.find_one({"phone": input_clean})
        if not user and not input_clean.startswith("+91"):
            user = users_collection.find_one({"mobile": "+91" + input_clean})

    if not user:
        user_id = f"usr_{os.urandom(4).hex()}"
        user = {
            "id": user_id,
            "phone": input_clean,
            "mobile": input_clean,
            "email": input_clean if is_email else "",
            "password": password_clean,
            "name": "Astrocare Admin" if credentials.role == "Admin" else "Divine Seeker",
            "role": credentials.role or "User",
            "gender": "Male",
            "dob": "1995-08-15",
            "timeOfBirth": "08:30 AM",
            "placeOfBirth": "Chennai, TN",
            "city": "Chennai",
            "state": "Tamil Nadu",
            "country": "India",
            "zodiac": "Leo (Simha)",
            "nakshatra": "Purva Phalguni",
            "lagna": "Leo",
            "walletBalance": 99999.0 if credentials.role == "Admin" else 750.0,
            "profilePhoto": "",
        }
        users_collection.insert_one(user)
        save_persistent_data()

    user.pop("_id", None)
    return {"status": "success", "message": "Login successful", "user": user}


@app.post("/api/auth/google")
def google_auth(google_data: GoogleAuth):
    email_clean = google_data.email.strip().lower()
    user = users_collection.find_one({"email": email_clean})

    if not user:
        user_id = f"usr_{os.urandom(4).hex()}"
        user = {
            "id": user_id,
            "email": email_clean,
            "phone": "+919876543210",
            "mobile": "+919876543210",
            "name": google_data.name.strip() or "Google Seeker",
            "role": google_data.role or "User",
            "gender": "Male",
            "dob": "1995-08-15",
            "timeOfBirth": "08:30 AM",
            "placeOfBirth": "Chennai, TN",
            "city": "Chennai",
            "state": "Tamil Nadu",
            "country": "India",
            "zodiac": "Leo (Simha)",
            "nakshatra": "Purva Phalguni",
            "lagna": "Leo",
            "walletBalance": 750.0,
            "profilePhoto": "",
        }
        users_collection.insert_one(user)
        save_persistent_data()

    user.pop("_id", None)
    return {"status": "success", "message": "Google authentication successful", "user": user}


@app.put("/api/users/profile")
def update_user_profile(user_model: UserModelSchema):
    doc = user_model.dict()
    user_id = doc.get("id") or doc.get("mobile")

    existing = users_collection.find_one({"id": user_id}) or users_collection.find_one({"mobile": doc.get("mobile")})

    if existing:
        users_collection.update_one({"_id": existing["_id"]}, {"$set": doc})
    else:
        users_collection.insert_one(doc)

    save_persistent_data()
    updated = users_collection.find_one({"mobile": doc.get("mobile")}) or doc
    if isinstance(updated, dict):
        updated.pop("_id", None)
    return {"status": "success", "message": "Profile saved to MongoDB successfully", "user": updated}


# ASTROLOGERS CRUD
@app.get("/api/astrologers")
def get_astrologers():
    docs = list(astrologers_collection.find({}, {"_id": 0}))
    return {"astrologers": docs}


@app.post("/api/astrologers", status_code=status.HTTP_201_CREATED)
def add_astrologer(ast: AstrologerSchema):
    data = ast.dict()
    email_clean = (data.get("email") or "").strip().lower()

    if email_clean:
        existing_ast = astrologers_collection.find_one({"email": email_clean})
        if existing_ast:
            raise HTTPException(status_code=400, detail=f"Astrologer with email '{email_clean}' already exists. Email must be unique.")

    if not data.get("id"):
        data["id"] = f"ast_{os.urandom(4).hex()}"

    astrologers_collection.insert_one(data)

    user_account = {
        "id": data["id"],
        "email": email_clean,
        "phone": data.get("mobile", ""),
        "mobile": data.get("mobile", ""),
        "password": data.get("password") or "password123",
        "name": data.get("name", "Astrologer"),
        "role": "Astrologer",
        "walletBalance": 102400.0,
    }
    users_collection.update_one({"id": data["id"]}, {"$set": user_account}, upsert=True)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "astrologer": data}


@app.put("/api/astrologers/{ast_id}")
def update_astrologer(ast_id: str, ast: AstrologerSchema):
    data = ast.dict()
    data["id"] = ast_id
    email_clean = (data.get("email") or "").strip().lower()

    if email_clean:
        existing_ast = astrologers_collection.find_one({"email": email_clean, "id": {"$ne": ast_id}})
        if existing_ast:
            raise HTTPException(status_code=400, detail=f"Astrologer with email '{email_clean}' already exists. Email must be unique.")

    astrologers_collection.update_one({"id": ast_id}, {"$set": data}, upsert=True)

    user_account = {
        "id": ast_id,
        "email": email_clean,
        "phone": data.get("mobile", ""),
        "mobile": data.get("mobile", ""),
        "password": data.get("password") or "password123",
        "name": data.get("name", "Astrologer"),
        "role": "Astrologer",
        "walletBalance": 102400.0,
    }
    users_collection.update_one({"id": ast_id}, {"$set": user_account}, upsert=True)
    save_persistent_data()
    return {"status": "success", "astrologer": data}


@app.delete("/api/astrologers/{ast_id}")
def delete_astrologer(ast_id: str):
    astrologers_collection.delete_one({"id": ast_id})
    save_persistent_data()
    return {"status": "success", "message": "Astrologer deleted from MongoDB"}


@app.put("/api/astrologers/{ast_id}/approve")
def approve_astrologer(ast_id: str):
    astrologers_collection.update_one({"id": ast_id}, {"$set": {"verificationStatus": "approved"}})
    save_persistent_data()
    return {"status": "success", "message": "Astrologer approved"}


@app.put("/api/astrologers/{ast_id}/reject")
def reject_astrologer(ast_id: str):
    astrologers_collection.update_one({"id": ast_id}, {"$set": {"verificationStatus": "rejected"}})
    save_persistent_data()
    return {"status": "success", "message": "Astrologer rejected"}


# TERMS & CONDITIONS CRUD
@app.get("/api/terms")
def get_terms():
    docs = list(terms_collection.find({}, {"_id": 0}).sort("orderIndex", 1))
    return {"terms": docs}


@app.post("/api/terms", status_code=status.HTTP_201_CREATED)
def add_term(term: TermSchema):
    data = term.dict()
    if not data.get("id"):
        data["id"] = f"tc_{os.urandom(4).hex()}"
    terms_collection.insert_one(data)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "term": data}


@app.put("/api/terms/{term_id}")
def edit_term(term_id: str, term: TermSchema):
    data = term.dict()
    data["id"] = term_id
    terms_collection.update_one({"id": term_id}, {"$set": data}, upsert=True)
    save_persistent_data()
    return {"status": "success", "term": data}


@app.delete("/api/terms/{term_id}")
def delete_term(term_id: str):
    terms_collection.delete_one({"id": term_id})
    save_persistent_data()
    return {"status": "success", "message": "Term deleted from MongoDB"}


# MAGAZINE ARTICLES CRUD
@app.get("/api/magazine")
def get_magazine_articles():
    docs = list(magazine_collection.find({}, {"_id": 0}))
    return {"articles": docs}


@app.post("/api/magazine", status_code=status.HTTP_201_CREATED)
def add_magazine_article(article: MagazineArticleSchema):
    data = article.dict()
    if not data.get("id"):
        data["id"] = f"mag_{os.urandom(4).hex()}"
    magazine_collection.insert_one(data)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "article": data}


@app.put("/api/magazine/{article_id}")
def edit_magazine_article(article_id: str, article: MagazineArticleSchema):
    data = article.dict()
    data["id"] = article_id
    magazine_collection.update_one({"id": article_id}, {"$set": data}, upsert=True)
    save_persistent_data()
    return {"status": "success", "article": data}


@app.delete("/api/magazine/{article_id}")
def delete_magazine_article(article_id: str):
    magazine_collection.delete_one({"id": article_id})
    save_persistent_data()
    return {"status": "success", "message": "Article deleted from MongoDB"}


# HOROSCOPE PREDICTIONS CRUD
@app.get("/api/horoscope/{sign}")
def get_horoscope(sign: str):
    doc = horoscope_collection.find_one({"zodiacSign": sign}, {"_id": 0})
    if not doc:
        return {"status": "default", "prediction": None}
    return {"status": "success", "prediction": doc}


@app.post("/api/horoscope")
def save_horoscope(prediction: HoroscopePredictionSchema):
    data = prediction.dict()
    horoscope_collection.update_one({"zodiacSign": data["zodiacSign"]}, {"$set": data}, upsert=True)
    save_persistent_data()
    return {"status": "success", "prediction": data}


@app.delete("/api/horoscope/{sign}")
def delete_horoscope(sign: str):
    horoscope_collection.delete_one({"zodiacSign": sign})
    save_persistent_data()
    return {"status": "success", "message": "Prediction deleted"}


# WALLET TRANSACTIONS
@app.get("/api/wallet/transactions")
def get_wallet_transactions(userId: Optional[str] = None):
    query = {"userId": userId} if userId else {}
    docs = list(wallet_collection.find(query, {"_id": 0}))
    return {"transactions": docs}


@app.post("/api/wallet/transactions")
def add_wallet_transaction(txn: WalletTransactionSchema):
    data = txn.dict()
    if not data.get("id"):
        data["id"] = f"txn_{os.urandom(4).hex()}"
    wallet_collection.insert_one(data)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "transaction": data}


# PANCHANG CRUD
@app.get("/api/panchang")
def get_panchang():
    docs = list(panchang_collection.find({}, {"_id": 0}))
    return {"panchang": docs}


@app.post("/api/panchang", status_code=status.HTTP_201_CREATED)
def add_panchang(panchang: PanchangSchema):
    data = panchang.dict()
    if not data.get("id"):
        data["id"] = f"panchang_{os.urandom(4).hex()}"
    panchang_collection.insert_one(data)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "panchang": data}


@app.put("/api/panchang/{panchang_id}")
def edit_panchang(panchang_id: str, panchang: PanchangSchema):
    data = panchang.dict()
    data["id"] = panchang_id
    panchang_collection.update_one({"id": panchang_id}, {"$set": data}, upsert=True)
    save_persistent_data()
    return {"status": "success", "panchang": data}


@app.delete("/api/panchang/{panchang_id}")
def delete_panchang(panchang_id: str):
    panchang_collection.delete_one({"id": panchang_id})
    save_persistent_data()
    return {"status": "success", "message": "Panchang entry deleted from MongoDB"}


# PLANET POSITIONS CRUD
@app.get("/api/planets")
def get_planet_positions():
    docs = list(planets_collection.find({}, {"_id": 0}))
    return {"planets": docs}


@app.post("/api/planets", status_code=status.HTTP_201_CREATED)
def add_planet_position(planet: PlanetPositionSchema):
    data = planet.dict()
    if not data.get("id"):
        data["id"] = f"plt_{os.urandom(4).hex()}"
    planets_collection.insert_one(data)
    save_persistent_data()
    data.pop("_id", None)
    return {"status": "success", "planet": data}


@app.put("/api/planets/{planet_id}")
def edit_planet_position(planet_id: str, planet: PlanetPositionSchema):
    data = planet.dict()
    data["id"] = planet_id
    planets_collection.update_one({"id": planet_id}, {"$set": data}, upsert=True)
    save_persistent_data()
    return {"status": "success", "planet": data}


@app.delete("/api/planets/{planet_id}")
def delete_planet_position(planet_id: str):
    planets_collection.delete_one({"id": planet_id})
    save_persistent_data()
    return {"status": "success", "message": "Planet position deleted from MongoDB"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
