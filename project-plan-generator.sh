#!/bin/bash

# Ideas Jar - Project Structure Generator
# This script creates the necessary folder structure and files for the Ideas Jar project

echo "Creating Ideas Jar Project Structure..."

# Create root directory
# mkdir -p ideas-jar

# Navigate to the root directory
# cd ideas-jar

# Create frontend directory structure
mkdir -p frontend/css frontend/js

# Create backend directory structure
mkdir -p backend/app/models backend/app/routes backend/app/services backend/database backend/tests

# Create DevOps directory
mkdir -p devops/ci-cd devops/docker

# Create docs directory
mkdir -p docs

# Create frontend files
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ideas Jar</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://unpkg.com/alpinejs" defer></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans" x-data="ideasApp()" x-init="init()">
  <div class="max-w-4xl mx-auto mt-10 p-6 bg-white rounded-2xl shadow-md">
    <!-- Header -->
    <div class="flex justify-between items-center mb-6">
      <div class="flex items-center gap-3">
        <div class="bg-blue-100 text-blue-600 p-2 rounded-full">
          <i class="fas fa-lightbulb text-xl"></i>
        </div>
        <h1 class="text-2xl font-semibold text-gray-800">Ideas Jar</h1>
      </div>
      <button @click="openModal()" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md shadow-sm">Add Idea</button>
    </div>

    <!-- Search Bar -->
    <div class="flex flex-col sm:flex-row gap-3 items-center mb-6">
      <input
        x-model="searchQuery"
        type="text"
        placeholder="Search ideas..."
        class="w-full sm:w-auto flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
      >
      <button @click="searchQuery = ''" class="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">Reset</button>
    </div>

    <!-- Table -->
    <div class="border rounded-lg overflow-hidden">
      <div class="px-4 py-3 border-b">
        <h2 class="font-semibold text-lg text-gray-800">Your Ideas</h2>
        <p class="text-sm text-gray-500">Total: <span x-text="filteredIdeas().length"></span> ideas</p>
      </div>
      <table class="w-full text-sm">
        <thead class="bg-gray-100 text-gray-600">
          <tr>
            <th class="text-left px-4 py-2">Idea</th>
            <th class="text-left px-4 py-2">Created</th>
            <th class="text-left px-4 py-2">Type</th>
            <th class="text-right px-4 py-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          <template x-for="idea in filteredIdeas()" :key="idea.id">
            <tr class="border-t hover:bg-gray-50">
              <td class="px-4 py-2 text-gray-800" x-text="idea.content"></td>
              <td class="px-4 py-2 text-gray-500" x-text="formatDate(idea.created_at)"></td>
              <td class="px-4 py-2">
                <span x-show="!idea.is_voice" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-700">
                  <i class="fas fa-keyboard mr-1"></i>Text
                </span>
                <span x-show="idea.is_voice" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-700">
                  <i class="fas fa-microphone mr-1"></i>Voice
                </span>
              </td>
              <td class="px-4 py-2 text-right">
                <button @click="editIdea(idea)" class="text-blue-600 hover:text-blue-800 mr-2">
                  <i class="fas fa-pen"></i>
                </button>
                <button @click="deleteIdea(idea.id)" class="text-gray-500 hover:text-red-600">
                  <i class="fas fa-trash"></i>
                </button>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Modal -->
  <div x-show="showModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" x-cloak>
    <div @click.outside="closeModal()" class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
      <h2 class="text-lg font-semibold mb-4" x-text="editIndex !== null ? 'Edit Idea' : 'Add Idea'"></h2>
      <textarea x-model="form.content" rows="4" placeholder="Enter your idea..." class="w-full border border-gray-300 rounded-md p-2 focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
      <div class="mt-4 flex justify-end gap-3">
        <button @click="closeModal()" class="px-4 py-2 border rounded-md text-gray-600 hover:bg-gray-100">Cancel</button>
        <button @click="submitIdea()" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">Save</button>
      </div>
    </div>
  </div>

  <script src="js/app.js"></script>
</body>
</html>
EOF

cat > frontend/js/app.js << 'EOF'
function ideasApp() {
  return {
    ideas: [],
    searchQuery: '',
    showModal: false,
    form: { content: '', is_voice: false },
    editIndex: null,

    init() {
      this.fetchIdeas();
    },

    async fetchIdeas() {
      try {
        const response = await fetch('http://localhost:8000/ideas');
        if (response.ok) {
          this.ideas = await response.json();
        } else {
          console.error('Failed to fetch ideas');
        }
      } catch (error) {
        console.error('Error fetching ideas:', error);
      }
    },

    filteredIdeas() {
      return this.ideas.filter(i => i.content.toLowerCase().includes(this.searchQuery.toLowerCase()));
    },

    openModal() {
      this.editIndex = null;
      this.form = { content: '', is_voice: false };
      this.showModal = true;
    },

    editIdea(idea) {
      this.editIndex = this.ideas.findIndex(i => i.id === idea.id);
      this.form = { content: idea.content, is_voice: idea.is_voice };
      this.showModal = true;
    },

    async deleteIdea(id) {
      try {
        const response = await fetch(`http://localhost:8000/ideas/${id}`, {
          method: 'DELETE',
        });

        if (response.ok) {
          this.ideas = this.ideas.filter(i => i.id !== id);
        } else {
          console.error('Failed to delete idea');
        }
      } catch (error) {
        console.error('Error deleting idea:', error);
      }
    },

    async submitIdea() {
      try {
        if (this.editIndex !== null) {
          // Update existing idea
          const id = this.ideas[this.editIndex].id;
          const response = await fetch(`http://localhost:8000/ideas/${id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(this.form),
          });

          if (response.ok) {
            const updatedIdea = await response.json();
            this.ideas[this.editIndex] = updatedIdea;
          } else {
            console.error('Failed to update idea');
          }
        } else {
          // Create new idea
          const response = await fetch('http://localhost:8000/ideas', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(this.form),
          });

          if (response.ok) {
            const newIdea = await response.json();
            this.ideas.unshift(newIdea);
          } else {
            console.error('Failed to create idea');
          }
        }
        this.closeModal();
      } catch (error) {
        console.error('Error submitting idea:', error);
      }
    },

    closeModal() {
      this.showModal = false;
    },

    formatDate(date) {
      const d = new Date(date);
      const now = new Date();
      const diff = Math.floor((now - d) / (1000 * 60 * 60 * 24));
      if (diff === 0) return 'Today';
      if (diff === 1) return 'Yesterday';
      if (diff < 7) return `${diff} days ago`;
      return d.toLocaleDateString();
    },
  }
}
EOF

# Create backend files
cat > backend/main.py << 'EOF'
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

# Load environment variables
load_dotenv()

# Database Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://username:password@localhost/ideasjar")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Priority Enum
class PriorityEnum(str, enum.Enum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

# Database Models
class IdeaDB(Base):
    __tablename__ = "ideas"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    is_voice = Column(Boolean, default=False)
    priority = Column(Enum(PriorityEnum), default=PriorityEnum.MEDIUM)
    improved_text = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Create tables
Base.metadata.create_all(bind=engine)

# Pydantic Models
class IdeaCreate(BaseModel):
    content: str
    is_voice: bool = False
    priority: PriorityEnum = PriorityEnum.MEDIUM

class IdeaUpdate(BaseModel):
    content: str
    is_voice: bool = False
    priority: PriorityEnum = PriorityEnum.MEDIUM

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
    return {"status": "healthy", "timestamp": datetime.utcnow()}

@app.get("/ideas", response_model=List[IdeaResponse])
async def get_ideas(
    skip: int = 0,
    limit: int = 100,
    priority: Optional[PriorityEnum] = None,
    db: Session = Depends(get_db)
):
    """Get all ideas with optional pagination and filtering"""
    query = db.query(IdeaDB)

    if priority:
        query = query.filter(IdeaDB.priority == priority)

    ideas = query.order_by(IdeaDB.created_at.desc()).offset(skip).limit(limit).all()
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
        is_voice=idea.is_voice,
        priority=idea.priority
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
    db_idea.priority = idea.priority
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

@app.post("/ideas/{idea_id}/improve", response_model=IdeaResponse)
async def improve_idea(idea_id: int, db: Session = Depends(get_db)):
    """Improve an idea using AI"""
    db_idea = db.query(IdeaDB).filter(IdeaDB.id == idea_id).first()
    if not db_idea:
        raise HTTPException(status_code=404, detail="Idea not found")

    # In a real implementation, this would call an AI service
    # For now, we'll just append a placeholder improved text
    db_idea.improved_text = f"Improved version: {db_idea.content}"
    db.commit()
    db.refresh(db_idea)
    return db_idea

@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """Get basic statistics about ideas"""
    total_ideas = db.query(IdeaDB).count()
    voice_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == True).count()
    text_ideas = db.query(IdeaDB).filter(IdeaDB.is_voice == False).count()

    high_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.HIGH).count()
    medium_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.MEDIUM).count()
    low_priority = db.query(IdeaDB).filter(IdeaDB.priority == PriorityEnum.LOW).count()

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# Create requirements.txt for backend
cat > backend/requirements.txt << 'EOF'
fastapi==0.103.1
uvicorn==0.23.2
sqlalchemy==2.0.20
psycopg2-binary==2.9.7
python-dotenv==1.0.0
python-multipart==0.0.6
pydantic==2.3.0
alembic==1.12.0
requests==2.31.0
pytest==7.4.2
EOF

# Create .env file for backend
cat > backend/.env << 'EOF'
DATABASE_URL=postgresql://username:password@localhost/ideasjar
EOF

# Create Docker files
cat > devops/docker/Dockerfile.backend << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend /app/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > devops/docker/Dockerfile.frontend << 'EOF'
FROM nginx:alpine

COPY frontend /usr/share/nginx/html
COPY devops/docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

cat > devops/docker/nginx.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

# Create docker-compose file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: devops/docker/Dockerfile.frontend
    ports:
      - "80:80"
    depends_on:
      - backend

  backend:
    build:
      context: .
      dockerfile: devops/docker/Dockerfile.backend
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/ideasjar

  db:
    image: postgres:15
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=ideasjar
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

# Create CI/CD pipeline file
cat > devops/ci-cd/github-actions.yml << 'EOF'
name: Ideas Jar CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ideasjar_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r backend/requirements.txt
        pip install pytest-cov safety

    - name: Run tests
      run: |
        cd backend
        pytest --cov=.
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ideasjar_test

    - name: Run security checks
      run: |
        safety check -r backend/requirements.txt

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_TOKEN }}

    - name: Build and push backend
      uses: docker/build-push-action@v4
      with:
        context: .
        file: devops/docker/Dockerfile.backend
        push: true
        tags: username/ideasjar-backend:latest

    - name: Build and push frontend
      uses: docker/build-push-action@v4
      with:
        context: .
        file: devops/docker/Dockerfile.frontend
        push: true
        tags: username/ideasjar-frontend:latest
EOF

# Create README file
cat > README.md << 'EOF'
# Ideas Jar

A responsive, professional voice/text Idea List app built with HTML/Tailwind CSS/Alpine.js on the frontend and FastAPI (Python) with PostgreSQL on the backend.

## Features

- Create, read, update, and delete ideas
- Voice-to-text input support
- Priority-based filtering (High, Medium, Low)
- Date-based filtering
- AI-powered idea improvement

## Project Structure