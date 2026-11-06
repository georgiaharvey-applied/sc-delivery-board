// Supabase connection for the SC Delivery Board.
// Find both values in Supabase: Project Settings > API.
// The anon key is designed to be public; the database rules in supabase/schema.sql
// are what keep the data private to @aaico.com and @appliedai.com accounts.
window.SC_CONFIG = {
  supabaseUrl: "https://YOUR-PROJECT-REF.supabase.co",
  supabaseAnonKey: "YOUR-ANON-KEY"
};
