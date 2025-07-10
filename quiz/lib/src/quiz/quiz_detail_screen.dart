import 'package:flutter/material.dart';
import 'package:quiz/config/supabase_config.dart';
import 'package:quiz/src/widgets/timer_widget.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({required this.quizId, super.key});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  List<dynamic> questions = [];
  Map<String, String> selectedAnswers = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final res = await supabase
        .from('questions')
        .select('*, choices(*)')
        .eq('quiz_id', widget.quizId);

    setState(() {
      questions = res;
      loading = false;
    });
  }

  Future<void> submit() async {
    int score = 0;

    for (var q in questions) {
      final correct = q['choices'].firstWhere((c) => c['is_correct'] == true);
      if (selectedAnswers[q['id']] == correct['id']) {
        score++;
      }
    }

    await supabase.from('user_scores').insert({
      'user_id': supabase.auth.currentUser!.id,
      'quiz_id': widget.quizId,
      'score': score,
      'completed_at': DateTime.now().toIso8601String(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Score"),
        content: Text("Your score: $score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          QuizTimer(
            totalSeconds: 60,
            onTimeUp: submit,
          ),
          ...questions.map((q) {
            final choices = q['choices'] as List<dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q['question_text'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ...choices.map((c) => RadioListTile<String>(
                      title: Text(c['choice_text']),
                      value: c['id'],
                      groupValue: selectedAnswers[q['id']],
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[q['id']] = value!;
                        });
                      },
                    )),
                const Divider(),
              ],
            );
          }).toList(),
          ElevatedButton(onPressed: submit, child: const Text("Submit")),
        ],
      ),
    );
  }
}
