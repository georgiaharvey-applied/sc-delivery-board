// Supabase connection for the SC Delivery Board.
// Find both values in Supabase: Project Settings > API.
// The anon key is designed to be public; the database rules in supabase/schema.sql
// are what keep the data private to @aaico.com and @appliedai.com accounts.
window.SC_CONFIG = {
  supabaseUrl: "https://lxzemvedfjtdgwgkpzcw.supabase.co",
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4emVtdmVkZmp0ZGd3Z2twemN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM5OTMxMTAsImV4cCI6MjEwOTU2OTExMH0.bxSwtNqqoZnEIrRRhnlyzEGAjv-ZpXj_eBFqkEgR0K8"
};
