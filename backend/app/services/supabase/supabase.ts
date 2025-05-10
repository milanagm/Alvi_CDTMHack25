import { createClient, SupabaseClient } from '@supabase/supabase-js';

// Initialize Supabase client with your environment variables
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL as string;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY as string;

if (!supabaseUrl || !supabaseKey) {
    throw new Error('Supabase URL and Key must be provided in environment variables');
}

const supabase: SupabaseClient = createClient(supabaseUrl, supabaseKey);
