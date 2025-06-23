## Base URL
All endpoints are relative to the base API URL (e.g., [http://localhost:8000](http://localhost:8000))
## Available Endpoints
### General
- GET / - Welcome message
- GET /health - Health check endpoint for API and database status

### Ideas Management
- GET /ideas - Get all ideas with pagination and optional filtering
    - Query Parameters:
        - skip: int (default: 0) - Number of items to skip
        - limit: int (default: 100) - Maximum number of items to return
        - priority: string (optional) - Filter by priority ("high", "medium", "low")

- GET /ideas/{idea_id} - Get a specific idea by ID
    - Path Parameters:
        - idea_id: int - The ID of the idea to retrieve

- POST /ideas - Create a new idea
    - Request Body:
        - content: string (required) - The content of the idea
        - is_voice: boolean (default: false) - Whether the idea was created using voice input
        - priority: string (default: "medium") - Priority level ("high", "medium", "low")

- PUT /ideas/{idea_id} - Update an existing idea
    - Path Parameters:
        - idea_id: int - The ID of the idea to update

    - Request Body:
        - content: string (required) - The updated content
        - is_voice: boolean (default: false) - Whether the idea was created using voice input
        - priority: string (default: "medium") - Priority level ("high", "medium", "low")

- DELETE /ideas/{idea_id} - Delete an idea
    - Path Parameters:
        - idea_id: int - The ID of the idea to delete

- GET /ideas/search/{query} - Search ideas by content
    - Path Parameters:
        - query: string - The search query string

- POST /ideas/{idea_id}/improve - Improve an idea using AI
    - Path Parameters:
        - idea_id: int - The ID of the idea to improve

### Statistics
- GET /stats - Get basic statistics about ideas
