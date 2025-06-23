
-- Create ideas table
CREATE TABLE ideas (
                       id SERIAL PRIMARY KEY,
                       content TEXT NOT NULL,
                       is_voice BOOLEAN DEFAULT FALSE,
                       priority priority_enum DEFAULT 'medium',
                       improved_text TEXT NULL,
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes to optimize filtering and queries
CREATE INDEX idx_ideas_created_at ON ideas(created_at);
CREATE INDEX idx_ideas_priority ON ideas(priority);
CREATE INDEX idx_ideas_content_search ON ideas USING gin(to_tsvector('english', content));

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function when a row is updated
CREATE TRIGGER update_ideas_updated_at
    BEFORE UPDATE ON ideas
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions (assuming user is 'postgres')
GRANT ALL PRIVILEGES ON DATABASE ideasjar TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;



