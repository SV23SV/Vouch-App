-- Vouch App Initial Schema
-- Privacy-first referral platform with trust-tiered visibility

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT,
  phone_hash TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  trust_score FLOAT DEFAULT 0.0,
  zip_code TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_phone_hash ON users(phone_hash);
CREATE INDEX idx_users_zip_code ON users(zip_code);

-- ============================================================================
-- PROS TABLE (Service Providers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS pros (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  avg_vouch_score FLOAT DEFAULT 0.0,
  phone_hash TEXT,
  zip_code TEXT,
  is_claimed BOOLEAN DEFAULT FALSE,
  claimed_by UUID REFERENCES users(id),
  license_photo_url TEXT,
  photo_gallery TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pros_phone_hash ON pros(phone_hash);
CREATE INDEX idx_pros_category ON pros(category);
CREATE INDEX idx_pros_zip_code ON pros(zip_code);

-- ============================================================================
-- VOUCHES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS vouches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pro_id UUID NOT NULL REFERENCES pros(id) ON DELETE CASCADE,
  price_paid_encrypted TEXT,
  note TEXT,
  safety_rating INTEGER DEFAULT 5 CHECK (safety_rating >= 1 AND safety_rating <= 5),
  visibility_level TEXT DEFAULT 'circle' CHECK (visibility_level IN ('circle', 'network', 'neighborhood')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vouches_user_id ON vouches(user_id);
CREATE INDEX idx_vouches_pro_id ON vouches(pro_id);

-- ============================================================================
-- CIRCLES TABLE (Friend Relationships)
-- ============================================================================
CREATE TABLE IF NOT EXISTS circles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_a_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'blocked')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_a_id, user_b_id)
);

CREATE INDEX idx_circles_user_a ON circles(user_a_id);
CREATE INDEX idx_circles_user_b ON circles(user_b_id);
CREATE INDEX idx_circles_status ON circles(status);

-- ============================================================================
-- ALERTS TABLE (Safety Reports)
-- ============================================================================
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reported_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pro_id UUID NOT NULL REFERENCES pros(id) ON DELETE CASCADE,
  alert_type TEXT NOT NULL CHECK (alert_type IN ('scam', 'warning')),
  description TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  location GEOGRAPHY(POINT, 4326),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_alerts_pro_id ON alerts(pro_id);
CREATE INDEX idx_alerts_reported_by ON alerts(reported_by);
CREATE INDEX idx_alerts_location ON alerts USING GIST(location);

-- ============================================================================
-- PRO LEADS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pro_leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pro_id UUID NOT NULL REFERENCES pros(id) ON DELETE CASCADE,
  seeker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pro_leads_pro_id ON pro_leads(pro_id);
CREATE INDEX idx_pro_leads_status ON pro_leads(status);

-- ============================================================================
-- INVITE LINKS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS invite_links (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inviter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_invite_links_code ON invite_links(code);

-- ============================================================================
-- TRUST BUNDLES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS trust_bundles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  vouch_ids UUID[] NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to update pro's average vouch score
CREATE OR REPLACE FUNCTION update_pro_avg_score()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE pros
  SET avg_vouch_score = (
    SELECT AVG(safety_rating)::FLOAT
    FROM vouches
    WHERE pro_id = NEW.pro_id
  )
  WHERE id = NEW.pro_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_pro_avg_score
AFTER INSERT OR UPDATE ON vouches
FOR EACH ROW EXECUTE FUNCTION update_pro_avg_score();

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
