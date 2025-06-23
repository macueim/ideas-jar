#!/usr/bin/env python3
"""
test-endpoints.py - Test script for Ideas Jar API endpoints

This script tests all endpoints defined in the Ideas Jar API by making
HTTP requests and displaying the responses. It creates, updates, and deletes
test data while validating the API's functionality.
"""

import requests
import json
from datetime import datetime
import time
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Base URL for the API
BASE_URL = "http://localhost:8000"

# Test idea data
TEST_IDEA = {
    "content": "Test idea created by test script",
    "is_voice": False,
    "priority": "medium"
}

TEST_IDEA_VOICE = {
    "content": "Test voice idea created by test script",
    "is_voice": True,
    "priority": "high"
}

UPDATE_IDEA = {
    "content": "Updated test idea content",
    "is_voice": False,
    "priority": "low"
}

def print_response(response, endpoint):
    """Pretty print the response from an API call"""
    logger.info(f"Testing endpoint: {endpoint}")
    logger.info(f"Status code: {response.status_code}")

    try:
        # Try to parse and print the JSON response
        response_json = response.json()
        logger.info(f"Response: {json.dumps(response_json, indent=2, sort_keys=True, default=str)}")
    except json.JSONDecodeError:
        # If response is not JSON, print the text
        logger.info(f"Response: {response.text}")

    logger.info("-" * 80)

def test_root():
    """Test the root endpoint"""
    endpoint = "/"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_health():
    """Test the health check endpoint"""
    endpoint = "/health"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_get_ideas():
    """Test getting all ideas"""
    endpoint = "/ideas"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

    # Test with pagination
    endpoint = "/ideas?skip=0&limit=5"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

    # Test with priority filter
    endpoint = "/ideas?priority=high"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_create_idea():
    """Test creating a new idea"""
    endpoint = "/ideas"
    response = requests.post(f"{BASE_URL}{endpoint}", json=TEST_IDEA)
    print_response(response, endpoint)

    # Create a voice idea with high priority too
    response_voice = requests.post(f"{BASE_URL}{endpoint}", json=TEST_IDEA_VOICE)
    print_response(response_voice, endpoint)

    # Return the created idea IDs for later tests
    return response.json()["id"], response_voice.json()["id"]

def test_get_idea(idea_id):
    """Test getting a specific idea by ID"""
    endpoint = f"/ideas/{idea_id}"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_update_idea(idea_id):
    """Test updating an idea"""
    endpoint = f"/ideas/{idea_id}"
    response = requests.put(f"{BASE_URL}{endpoint}", json=UPDATE_IDEA)
    print_response(response, endpoint)

def test_improve_idea(idea_id):
    """Test improving an idea using AI"""
    endpoint = f"/ideas/{idea_id}/improve"
    response = requests.post(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_search_ideas():
    """Test searching for ideas"""
    search_term = "test"
    endpoint = f"/ideas/search/{search_term}"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_stats():
    """Test getting statistics"""
    endpoint = "/stats"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_delete_idea(idea_id):
    """Test deleting an idea"""
    endpoint = f"/ideas/{idea_id}"
    response = requests.delete(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def test_error_cases():
    """Test error handling for various scenarios"""
    # Test invalid idea ID
    endpoint = "/ideas/99999"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

    # Test empty idea content
    endpoint = "/ideas"
    response = requests.post(f"{BASE_URL}{endpoint}", json={"content": "", "is_voice": False})
    print_response(response, endpoint)

    # Test invalid priority
    endpoint = "/ideas?priority=invalid"
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response, endpoint)

def run_all_tests():
    """Run all tests in sequence"""
    logger.info("Starting API endpoint tests...")

    try:
        # Test basic endpoints
        test_root()
        test_health()

        # Test getting ideas (before we create test data)
        test_get_ideas()

        # Test creating ideas and get their IDs
        idea_id, voice_idea_id = test_create_idea()

        # Test operations on individual ideas
        test_get_idea(idea_id)
        test_update_idea(idea_id)
        test_improve_idea(voice_idea_id)

        # Test search and stats
        test_search_ideas()
        test_stats()

        # Test error cases
        test_error_cases()

        # Test deleting ideas (cleanup)
        test_delete_idea(idea_id)
        test_delete_idea(voice_idea_id)

        logger.info("All tests completed successfully!")

    except requests.exceptions.ConnectionError:
        logger.error("Connection error. Make sure the API server is running.")
    except Exception as e:
        logger.error(f"Test failed with error: {str(e)}")

if __name__ == "__main__":
    run_all_tests()