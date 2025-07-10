import 'package:quiz/config/supabase_config.dart';

Future<List<Map<String, dynamic>>> getLeaderboard() async {
  final response = await supabase
      .from('user_scores')
      .select('score, user_id')
      .order('score', ascending: false)
      .limit(10);

  return List<Map<String, dynamic>>.from(response);
}
