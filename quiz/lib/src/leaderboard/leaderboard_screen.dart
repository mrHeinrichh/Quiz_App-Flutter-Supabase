import 'package:flutter/material.dart';
import 'package:quiz/config/supabase_config.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    final res = await supabase
        .from('user_scores')
        .select('score, user_id')
        .order('score', ascending: false)
        .limit(10);

    setState(() {
      leaderboard = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard")),
      body: ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final entry = leaderboard[index];
          return ListTile(
            title: Text("User ID: ${entry['user_id']}"),
            trailing: Text("Score: ${entry['score']}"),
          );
        },
      ),
    );
  }
}
