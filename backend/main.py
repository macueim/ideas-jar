from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Text, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional
import os
from dotenv import load_dotenv
import enum
import logging
import psycopg2
import psycopg2

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# Database Configuration
DATABASE_URL = os.getenv("DATABASE_URL")
logger.info(f"Using database URL: {DATABASE_URL}")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set")

# Configure SQLAlchemy engine with proper parameters
engine = create_engine(
    DATABASE_URL,
    echo=True,  # Log SQL queries for debugging
    pool_pre_ping=True  # Verify connections before using them
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Priority Enum
class PriorityEnum(str, enum.Enum):
    high = "high"
    medium = "medium"
    low = "low"

# Database Models
class IdeaDB(Base):
    __tablename__ = "ideas"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    is_voice = Column(Boolean, default=False)
    priority = Column(Enum(PriorityEnum, name="priority_enum", create_type=False), default=PriorityEnum.medium)
    improved_text = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, index=True)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

# Don't try to create the priority_enum type as it should already exist in the database
# Just check if tables exist and create them if they don't
try:
    # Check if the table exists before trying to create it
    conn = engine.connect()
    if not engine.dialect.has_table(conn, "ideas"):
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created successfully")
    else:
        logger.info("Tables already exist, skipping creation")
    conn.close()
except Exception as e:
    logger.error(f"Error checking/creating database tables: {e}")
    raise

# Pydantic Models
class IdeaCreate(BaseModel):
    content: str
    is_voice: bool = False
    priority: PriorityEnum = PriorityEnum.medium

class IdeaUpdate(BaseModel):
    content: str
    is_voice: bool = False
    priority: PriorityEnum = PriorityEnum.medium

class IdeaResponse(BaseModel):
    id: int
    content: str
    is_voice: bool
    priority: PriorityEnum
    improved_text: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# FastAPI App
app = FastAPI(
    title="Ideas Jar API",
    description="A simple API for managing ideas with voice and text input",
    version="1.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# API Routes
@app.get("/")
async def root():
    return {"message": "Welcome to Ideas Jar API"}

@app.get("/health")
async def health_check():
    try:
        # Test database connection
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        return {"status": "healthy", "timestamp": datetime.utcnow(), "database": "connected"}
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {"status": "unhealthy", "timestamp": datetime.utcnow(), "error": str(e)}

# Route order matters - put specific routes before general ones
@app.get("/ideas/search/{query}", response_model=List[IdeaResponse])
async def search_ideas(query: str, db: Session = Depends(get_db)):
    """Search ideas by content"""
    try:
        ideas = db.query(IdeaDB).filter(
            IdeaDB.content.ilike(f"%{query}%")
        ).order_by(IdeaDB.created_at.desc()).all()
        return ideas
    except Exception as e:
        logger.error(f"Error searching ideas: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/ideas", response_model=List[IdeaResponse])
async def get_ideas(
        skip: int = 0,
        limit: int = 100,
        priority: Optional[PriorityEnum] = None,
        db: Session = Depends(get_db)
):
    """Get all ideas with optional pagination and filtering"""
    try:
        query = db.query(IdeaDB)

        if priority:
            query = query.filter(IdeaDB.priority == priority)

        ideas = query.order_by(IdeaDB.created_at.desc()).offset(skip).limit(limit).all()
        return ideas
    except Exception as e:
        logger.error(f"Error getting ideas: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/ideas/{idea_id}", response_model=IdeaResponse)
async def get_idea(idea_id: int, db: Session = Depends(get_db)):
    """Get a specific idea by ID"""
    idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    return idea

@app.post("/ideas/{idea_id}/improve", response_model=IdeaResponse)
async def improve_idea(idea_id: int, db: Session = Depends(get_db)):
    """Improve an idea using AI"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    try:
        # In a real implementation, this would call an AI service
        # For now, we'll just append a placeholder improved text
        db_idea.improved_text = f"Improved version: {db_idea.content}"
        db.commit()
        db.refresh(db_idea)
        return db_idea
    except Exception as e:
        db.rollback()
        logger.error(f"Error improving idea: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.post("/ideas", response_model=IdeaResponse)
async def create_idea(idea: IdeaCreate, db: Session = Depends(get_db)):
    """Create a new idea"""
    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Idea content cannot be empty")

    try:
        db_idea = IdeaDB(
            content=idea.content.strip(),
            is_voice=idea.is_voice,
            priority=idea.priority
        )
        db.add(db_idea)
        db.commit()
        db.refresh(db_idea)
        return db_idea
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating idea: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.put("/ideas/{idea_id}", response_model=IdeaResponse)
async def update_idea(idea_id: int, idea: IdeaUpdate, db: Session = Depends(get_db)):
    """Update an existing idea"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Idea content cannot be empty")

    try:
        db_idea.content = idea.content.strip()
        db_idea.is_voice = idea.is_voice
        db_idea.priority = idea.priority
        db_idea.updated_at = datetime.utcnow()

        db.commit()
        db.refresh(db_idea)
        return db_idea
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating idea: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.delete("/ideas/{idea_id}")
async def delete_idea(idea_id: int, db: Session = Depends(get_db)):
    """Delete an idea"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    try:
        db.delete(db_idea)
        db.commit()
        return {"message": "Idea deleted successfully"}
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting idea: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """Get basic statistics about ideas"""
    try:
        total_ideas = db.query(IdeaDB).count()

        if total_ideas == 0:
            return {
                "total_ideas": 0,
                "voice_ideas": 0,
                "text_ideas": 0,
                "voice_percentage": 0,
                "priority_breakdown": {
                    "high": 0,
                    "medium": 0,
                    "low": 0
                }
            }

        voice_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == True).count()
        text_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == False).count()

        high_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.high).count()
        medium_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.medium).count()
        low_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.low).count()

        return {
            "total_ideas": total_ideas,
            "voice_ideas": voice_ideas,
            "text_ideas": text_ideas,
            "voice_percentage": round((voice_ideas / total_ideas * 100) if total_ideas > 0 else 0, 2),
            "priority_breakdown": {
                "high": high_priority,
                "medium": medium_priority,
                "low": low_priority
            }
        }
    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)