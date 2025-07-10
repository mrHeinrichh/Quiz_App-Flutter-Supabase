import 'package:flutter/material.dart';
import 'package:quiz/src/quiz/create_quiz_screen.dart';
import 'package:quiz/src/quiz/quiz_detail_screen.dart';
import 'package:quiz/src/leaderboard/leaderboard_screen.dart';
import 'package:quiz/config/supabase_config.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<dynamic> quizzes = [];
  bool loading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
    checkAdmin();
  }

  Future<void> loadQuizzes() async {
    final res = await supabase
        .from('quizzes')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    setState(() {
      quizzes = res;
      loading = false;
    });
  }

  Future<void> checkAdmin() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final res = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', userId)
        .single();

    setState(() {
      isAdmin = res['is_admin'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Available Quizzes")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return ListTile(
                  title: Text(quiz['title']),
                  subtitle: Text(quiz['description'] ?? ""),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizDetailScreen(quizId: quiz['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            child: const Text("View Leaderboard"),
          ),
          if (isAdmin)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
                );
              },
              child: const Text("Create Quiz (Admin)"),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
