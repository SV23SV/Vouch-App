// Supabase Edge Function: match-hashes
// Receives hashed phone numbers and returns matching user IDs.
// No raw phone numbers are ever received or stored.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    // Get the requesting user
    const {
      data: { user },
    } = await supabaseClient.auth.getUser();

    if (!user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body
    const { hashed_phones } = await req.json();

    if (!Array.isArray(hashed_phones) || hashed_phones.length === 0) {
      return new Response(
        JSON.stringify({ error: "hashed_phones array is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate all entries look like SHA-256 hashes (64 hex chars)
    const hashPattern = /^[a-f0-9]{64}$/;
    for (const hash of hashed_phones) {
      if (!hashPattern.test(hash)) {
        return new Response(
          JSON.stringify({
            error: "Invalid hash format detected. All entries must be SHA-256 hashes.",
          }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    // Batch query: find users whose phone_hash matches any of the provided hashes
    // Exclude the requesting user themselves
    const { data: matches, error } = await supabaseClient
      .from("users")
      .select("id, display_name, avatar_url, phone_hash")
      .in_("phone_hash", hashed_phones)
      .neq("id", user.id);

    if (error) {
      throw error;
    }

    // Return matched users (without exposing phone_hash to the client)
    const results = (matches ?? []).map((match: any) => ({
      id: match.id,
      display_name: match.display_name,
      avatar_url: match.avatar_url,
    }));

    return new Response(
      JSON.stringify({ matches: results, count: results.length }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
