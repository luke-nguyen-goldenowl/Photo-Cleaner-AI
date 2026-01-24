import 'package:myapp/src/config/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late SupabaseClient supabaseClient;
Future<void> initializeSupabase() async {
  //await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: ENV.supabaseUrl,
    anonKey: ENV.supabaseKey,
  );
  supabaseClient = Supabase.instance.client;
}
