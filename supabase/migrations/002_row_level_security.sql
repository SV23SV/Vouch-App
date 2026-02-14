-- Vouch App Row Level Security Policies
-- Core trust-gating mechanism: users can only see data within their circle

-- ============================================================================
-- Enable RLS on all tables
-- ============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE pros ENABLE ROW LEVEL SECURITY;
ALTER TABLE vouches ENABLE ROW LEVEL SECURITY;
ALTER TABLE circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pro_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE trust_bundles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USERS POLICIES
-- ============================================================================

-- Users can read basic profiles of other users
CREATE POLICY users_select ON users
  FOR SELECT TO authenticated
  USING (true);

-- Users can only update their own profile
CREATE POLICY users_update ON users
  FOR UPDATE TO authenticated
  USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY users_insert ON users
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- PROS POLICIES
-- ============================================================================

-- Anyone authenticated can view pros
CREATE POLICY pros_select ON pros
  FOR SELECT TO authenticated
  USING (true);

-- Anyone authenticated can create a pro listing
CREATE POLICY pros_insert ON pros
  FOR INSERT TO authenticated
  WITH CHECK (true);

-- Only the claimed owner can update a pro
CREATE POLICY pros_update ON pros
  FOR UPDATE TO authenticated
  USING (claimed_by = auth.uid());

-- ============================================================================
-- VOUCHES POLICIES (Core Trust Gate)
-- ============================================================================

-- Users can only see vouches from people in their circle
CREATE POLICY vouches_select ON vouches
  FOR SELECT TO authenticated
  USING (
    -- User can see their own vouches
    user_id = auth.uid()
    OR
    -- User can see vouches from 1st-degree circle members
    user_id IN (
      SELECT CASE
        WHEN user_a_id = auth.uid() THEN user_b_id
        WHEN user_b_id = auth.uid() THEN user_a_id
      END
      FROM circles
      WHERE (user_a_id = auth.uid() OR user_b_id = auth.uid())
        AND status = 'active'
    )
    OR
    -- Neighborhood-level vouches visible by zip code
    (
      visibility_level = 'neighborhood'
      AND user_id IN (
        SELECT id FROM users
        WHERE zip_code = (SELECT zip_code FROM users WHERE id = auth.uid())
      )
    )
  );

-- Users can only insert their own vouches
CREATE POLICY vouches_insert ON vouches
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can only update their own vouches
CREATE POLICY vouches_update ON vouches
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

-- Users can only delete their own vouches
CREATE POLICY vouches_delete ON vouches
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- CIRCLES POLICIES
-- ============================================================================

-- Users can only see circle records they are part of
CREATE POLICY circles_select ON circles
  FOR SELECT TO authenticated
  USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- Users can create circle invitations (they must be user_a)
CREATE POLICY circles_insert ON circles
  FOR INSERT TO authenticated
  WITH CHECK (user_a_id = auth.uid());

-- Users can update circles they are part of (accept/decline/block)
CREATE POLICY circles_update ON circles
  FOR UPDATE TO authenticated
  USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- Users can delete circles they are part of
CREATE POLICY circles_delete ON circles
  FOR DELETE TO authenticated
  USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- ============================================================================
-- ALERTS POLICIES
-- ============================================================================

-- All authenticated users can read alerts in their area
CREATE POLICY alerts_select ON alerts
  FOR SELECT TO authenticated
  USING (true);

-- Any authenticated user can create an alert
CREATE POLICY alerts_insert ON alerts
  FOR INSERT TO authenticated
  WITH CHECK (reported_by = auth.uid());

-- Only the reporter can update their alert
CREATE POLICY alerts_update ON alerts
  FOR UPDATE TO authenticated
  USING (reported_by = auth.uid());

-- Only the reporter can delete their alert
CREATE POLICY alerts_delete ON alerts
  FOR DELETE TO authenticated
  USING (reported_by = auth.uid());

-- ============================================================================
-- PRO LEADS POLICIES
-- ============================================================================

-- Pros can see leads for their business; seekers can see their own leads
CREATE POLICY pro_leads_select ON pro_leads
  FOR SELECT TO authenticated
  USING (
    seeker_id = auth.uid()
    OR
    pro_id IN (SELECT id FROM pros WHERE claimed_by = auth.uid())
  );

-- Any authenticated user can create a lead (by calling a pro)
CREATE POLICY pro_leads_insert ON pro_leads
  FOR INSERT TO authenticated
  WITH CHECK (seeker_id = auth.uid());

-- Pros can update lead status
CREATE POLICY pro_leads_update ON pro_leads
  FOR UPDATE TO authenticated
  USING (
    pro_id IN (SELECT id FROM pros WHERE claimed_by = auth.uid())
  );

-- ============================================================================
-- INVITE LINKS POLICIES
-- ============================================================================

-- Users can see their own invite links
CREATE POLICY invite_links_select ON invite_links
  FOR SELECT TO authenticated
  USING (inviter_id = auth.uid() OR used_by = auth.uid());

-- Users can create invite links
CREATE POLICY invite_links_insert ON invite_links
  FOR INSERT TO authenticated
  WITH CHECK (inviter_id = auth.uid());

-- ============================================================================
-- TRUST BUNDLES POLICIES
-- ============================================================================

-- Creators can see their bundles
CREATE POLICY trust_bundles_select ON trust_bundles
  FOR SELECT TO authenticated
  USING (creator_id = auth.uid());

-- Users can create bundles
CREATE POLICY trust_bundles_insert ON trust_bundles
  FOR INSERT TO authenticated
  WITH CHECK (creator_id = auth.uid());
