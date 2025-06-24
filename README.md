# Ideas Jar

Ideas Jar is a responsive, professional application for capturing and managing ideas through both text and voice input. It features a modern web frontend built with HTML, Tailwind CSS, and Alpine.js, with a robust backend powered by FastAPI (Python) and PostgreSQL.

## 📋 Features

- **Idea Management**: Create, read, update, and delete ideas
- **Voice Input**: Record ideas using voice-to-text functionality
- **Priority Management**: Assign High, Medium, or Low priority to ideas
- **Advanced Filtering**: Filter ideas by priority level and date
- **Search Functionality**: Quickly find ideas with text search
- **AI-powered Enhancement**: Improve your ideas with AI assistance
- **Statistics Dashboard**: Track idea metrics and usage patterns

## 🏗️ Architecture

The application is built using a modern client-server architecture:

### Frontend

- **HTML5** with responsive design principles
- **Tailwind CSS** for utility-first styling
- **Alpine.js** for lightweight reactive data binding
- **Font Awesome** for icons and visual elements

### Backend

- **FastAPI** framework for high-performance API development
- **SQLAlchemy ORM** for database interactions
- **PostgreSQL** (with Supabase support) for data persistence
- **Pydantic** for data validation and settings management

## 🚀 Getting Started

### Prerequisites

- Python 3.12+
- PostgreSQL database (or Supabase account)
- Modern web browser

### Installation

1. Clone the repository:

```

   git clone https://github.com/macueim/ideas-jar.git
   cd ideas-jar
```

2. Set up the backend:

```

   cd backend
   pip install -r requirements.txt
```

3. Configure environment variables: Create a `.env` file in the backend directory with:

```

   DATABASE_URL=your_database_url
   SUPABASE_KEY=your_supabase_key (if using Supabase)
```

4. Start the backend server:

```

   python main.py
```

5. Open the frontend: Navigate to `frontend/index.html` in your web browser or serve it using a web server.

## 🔌 API Reference

The Ideas Jar API provides endpoints for managing ideas and retrieving statistics.

### Base URL

All endpoints are relative to the base API URL (e.g., [https://ideas-jar-client.onrender.com](https://ideas-jar-client.onrender.com/))

### General Endpoints

#### Welcome Message

```

GET /
```

Returns a welcome message.

**Response:**

```

{  "message": "Welcome to Ideas Jar API"}
```

#### Health Check

```

GET /health
```

Returns the health status of the API and database connection.

**Response:**

```

{  "status": "healthy",  "timestamp": "2023-06-01T12:00:00.000Z",  "database": "connected"}
```

### Idea Management Endpoints

#### Get All Ideas

```

GET /ideas
```

Retrieves a list of ideas with optional pagination and filtering.

**Query Parameters:**

- `skip` (int, default: 0): Number of items to skip
- `limit` (int, default: 100): Maximum number of items to return
- `priority` (string, optional): Filter by priority ("high", "medium", "low")

**Response:** List of idea objects

#### Get Idea by ID

```

GET /ideas/{idea_id}
```

Retrieves a specific idea by its ID.

**Path Parameters:**

- `idea_id` (int): The ID of the idea to retrieve

**Response:** Single idea object

#### Create New Idea

```

POST /ideas
```

Creates a new idea.

**Request Body:**

- `content` (string, required): The content of the idea
- `is_voice` (boolean, default: false): Whether the idea was created using voice input
- `priority` (string, default: "medium"): Priority level ("high", "medium", "low")

**Response:** Created idea object

#### Update Idea

```

PUT /ideas/{idea_id}
```

Updates an existing idea.

**Path Parameters:**

- `idea_id` (int): The ID of the idea to update

**Request Body:**

- `content` (string, required): The updated content
- `is_voice` (boolean, default: false): Whether the idea was created using voice input
- `priority` (string, default: "medium"): Priority level ("high", "medium", "low")

**Response:** Updated idea object

#### Delete Idea

```

DELETE /ideas/{idea_id}
```

Deletes an idea.

**Path Parameters:**

- `idea_id` (int): The ID of the idea to delete

**Response:**

```

{  "message": "Idea deleted successfully"}
```

#### Search Ideas

```

GET /ideas/search/{query}
```

Searches ideas by content.

**Path Parameters:**

- `query` (string): The search query string

**Response:** List of matching idea objects

#### Improve Idea with AI

```

POST /ideas/{idea_id}/improve
```

Improves an idea using AI.

**Path Parameters:**

- `idea_id` (int): The ID of the idea to improve

**Response:** Idea object with improved_text field populated

### Statistics Endpoint

#### Get Idea Statistics

```

GET /stats
```

Retrieves basic statistics about ideas.

**Response:**

```

{  "total_ideas": 10,  "voice_ideas": 3,  "text_ideas": 7,  "voice_percentage": 30.0,  "priority_breakdown": {    "high": 2,    "medium": 5,    "low": 3  }}
```

## 📦 Project Structure

```

ideas-jar/
├── backend/              # FastAPI backend
│   ├── app/              # Application modules
│   ├── database/         # Database models and configuration
│   ├── tests/            # Backend tests
│   ├── .env              # Environment variables
│   ├── main.py           # Main FastAPI application
│   └── requirements.txt  # Python dependencies
├── frontend/             # Web frontend
│   ├── css/              # Stylesheets
│   ├── js/               # JavaScript files
│   ├── index.html        # Main HTML file
│   └── endpoints_list.md # API documentation
├── devops/               # Deployment and CI/CD files
└── docs/                 # Additional documentation
```

## 🔧 Development

### Backend Development

The backend is built with FastAPI and uses SQLAlchemy for database operations. Key components:

- **Models**: Database models for ideas with properties like content, priority, and timestamps
- **API Routes**: REST endpoints for CRUD operations and statistics
- **Validation**: Request/response validation using Pydantic models
- **Error Handling**: Comprehensive error handling with appropriate HTTP status codes
- **Database Integration**: Support for PostgreSQL with optional Supabase configuration

### Frontend Development

The frontend uses Alpine.js for reactivity and Tailwind CSS for styling:

- **UI Components**: Responsive components designed for desktop and mobile use
- **State Management**: Alpine.js handles application state and UI interactions
- **API Integration**: Fetch API for backend communication with fallback to local data
- **Voice Input**: Integration with Web Speech API for voice-to-text functionality
- **Styling**: Modern, clean UI with Tailwind CSS utility classes

## 🧪 Testing

- Run backend tests using pytest:

```

  cd backend
  pytest
```

- Manual testing of the frontend can be done by opening the HTML file directly or using a local server.

## 🚀 Deployment

### Backend Deployment

The FastAPI backend can be deployed to various platforms:

1. **Docker**: Use the included Docker configuration for containerized deployment
2. **Heroku**: Deploy directly to Heroku with Procfile support
3. **Cloud Providers**: AWS, GCP, or Azure with appropriate configurations

### Frontend Deployment

The frontend can be deployed to:

1. **Static Hosting**: GitHub Pages, Netlify, or Vercel
2. **CDN**: Any content delivery network supporting static files
3. **Traditional Web Hosting**: Any web hosting service

## 🔐 Security

- CORS is configured to protect against unauthorized access
- Input validation prevents injection attacks
- Database connections are secured with environment variables
- Error handling prevents information disclosure

## 🛣️ Roadmap

- **Mobile App**: Native mobile applications for iOS and Android
- **Advanced AI**: Enhanced AI idea improvement capabilities
- **Collaboration**: Multi-user collaboration features
- **Categories**: Organize ideas into categories and collections
- **Export Options**: Export ideas to various formats (PDF, CSV, etc.)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request