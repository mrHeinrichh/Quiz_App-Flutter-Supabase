import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://knaqltaaldasmjgrocdw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuYXFsdGFhbGRhc21qZ3JvY2R3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxMzI5NjMsImV4cCI6MjA2NzcwODk2M30.d72nB5fpklJ_7gjEP5mmYzlOtUT6w5BIQTVgx8PyV3E',
  );
}

final supabase = Supabase.instance.client;
