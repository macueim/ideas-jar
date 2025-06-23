# main.py
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://username:password@localhost/ideasjar")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Database Models
class IdeaDB(Base):
    __tablename__ = "ideas"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    is_voice = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# Create tables
Base.metadata.create_all(bind=engine)


# Pydantic Models
class IdeaCreate(BaseModel):
    content: str
    is_voice: bool = False


class IdeaUpdate(BaseModel):
    content: str
    is_voice: bool = False


class IdeaResponse(BaseModel):
    id: int
    content: str
    is_voice: bool
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
    return {"status": "healthy", "timestamp": datetime.utcnow()}


@app.get("/ideas", response_model=List[IdeaResponse])
async def get_ideas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all ideas with optional pagination"""
    ideas = db.query(IdeaDB).order_by(IdeaDB.created_at.desc()).offset(skip).limit(limit).all()
    return ideas


@app.get("/ideas/{idea_id}", response_model=IdeaResponse)
async def get_idea(idea_id: int, db: Session = Depends(get_db)):
    """Get a specific idea by ID"""
    idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    return idea


@app.post("/ideas", response_model=IdeaResponse)
async def create_idea(idea: IdeaCreate, db: Session = Depends(get_db)):
    """Create a new idea"""
    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Idea content cannot be empty")

    db_idea = IdeaDB(
        content=idea.content.strip(),
        is_voice=idea.is_voice
    )
    db.add(db_idea)
    db.commit()
    db.refresh(db_idea)
    return db_idea


@app.put("/ideas/{idea_id}", response_model=IdeaResponse)
async def update_idea(idea_id: int, idea: IdeaUpdate, db: Session = Depends(get_db)):
    """Update an existing idea"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Idea content cannot be empty")

    db_idea.content = idea.content.strip()
    db_idea.is_voice = idea.is_voice
    db_idea.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(db_idea)
    return db_idea


@app.delete("/ideas/{idea_id}")
async def delete_idea(idea_id: int, db: Session = Depends(get_db)):
    """Delete an idea"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    db.delete(db_idea)
    db.commit()
    return {"message": "Idea deleted successfully"}


@app.get("/ideas/search/{query}", response_model=List[IdeaResponse])
async def search_ideas(query: str, db: Session = Depends(get_db)):
    """Search ideas by content"""
    ideas = db.query(IdeaDB).filter(
        IdeaDB.content.ilike(f"%{query}%")
    ).order_by(IdeaDB.created_at.desc()).all()
    return ideas


# Statistics endpoint
@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """Get basic statistics about ideas"""
    total_ideas = db.query(IdeaDB).count()
    voice_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == True).count()
    text_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == False).count()

    return {
        "total_ideas": total_ideas,
        "voice_ideas": voice_ideas,
        "text_ideas": text_ideas,
        "voice_percentage": round((voice_ideas / total_ideas * 100) if total_ideas > 0 else 0, 2)
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)