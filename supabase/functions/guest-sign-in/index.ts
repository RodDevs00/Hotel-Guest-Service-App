import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const attempts = new Map<string, { count: number; resetAt: number }>();

function rateLimited(key: string): boolean {
  const now = Date.now();
  const entry = attempts.get(key);
  if (!entry || entry.resetAt < now) {
    attempts.set(key, { count: 1, resetAt: now + 60_000 });
    return false;
  }
  entry.count += 1;
  return entry.count > 10;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { room_number, check_in_code } = await req.json();
    if (!room_number || !check_in_code) {
      return new Response(JSON.stringify({ error: "Room number and check-in code are required." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const ip = req.headers.get("x-forwarded-for") ?? "unknown";
    const rateKey = `${ip}:${String(room_number).trim()}`;
    if (rateLimited(rateKey)) {
      return new Response(JSON.stringify({ error: "Too many attempts. Try again in a minute." }), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    const { data: matches, error: verifyError } = await admin.rpc(
      "verify_guest_credentials",
      {
        p_room_number: String(room_number).trim(),
        p_check_in_code: String(check_in_code).trim(),
      },
    );

    if (verifyError) {
      return new Response(JSON.stringify({ error: verifyError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const match = Array.isArray(matches) ? matches[0] : matches;
    if (!match) {
      return new Response(JSON.stringify({ error: "Invalid room number or check-in code." }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const stayId = match.stay_id as string;
    const roomId = match.room_id as string;
    let userId = match.guest_user_id as string | null;
    const email = `guest-${stayId}@hotel.local`;
    const password = crypto.randomUUID() + crypto.randomUUID();

    if (userId) {
      const { error: updateError } = await admin.auth.admin.updateUserById(userId, {
        password,
        app_metadata: { role: "guest", stay_id: stayId, room_id: roomId },
        user_metadata: { full_name: `Guest Room` },
        email_confirm: true,
      });
      if (updateError) {
        return new Response(JSON.stringify({ error: updateError.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    } else {
      const { data: created, error: createError } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        app_metadata: { role: "guest", stay_id: stayId, room_id: roomId },
        user_metadata: { full_name: "Guest" },
      });
      if (createError || !created.user) {
        return new Response(
          JSON.stringify({ error: createError?.message ?? "Could not create guest user." }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      userId = created.user.id;
      await admin.from("stays").update({ guest_user_id: userId }).eq("id", stayId);
    }

    return new Response(JSON.stringify({ email, password, stay_id: stayId }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
