CREATE TABLE saved_routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  origin JSONB NOT NULL,
  stops JSONB NOT NULL,
  distance_meters INT NOT NULL,
  duration_seconds INT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE saved_routes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view own saved routes"
  ON saved_routes FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "User can insert own saved routes"
  ON saved_routes FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "User can update own saved routes"
  ON saved_routes FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "User can delete own saved routes"
  ON saved_routes FOR DELETE USING (user_id = auth.uid());

CREATE INDEX saved_routes_user_id_idx ON saved_routes(user_id);
